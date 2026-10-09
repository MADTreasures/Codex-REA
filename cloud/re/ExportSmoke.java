import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.program.model.listing.Function;
import java.io.File;
import java.io.PrintWriter;

/** Verify actual recovery, including the arithmetic in our own harmless fixture. */
public class ExportSmoke extends GhidraScript {
    public void run() throws Exception {
        DecompInterface decompiler = new DecompInterface();
        try {
            if (!decompiler.openProgram(currentProgram)) {
                throw new IllegalStateException("Decompiler could not open program");
            }
            int found = 0;
            try (PrintWriter out = new PrintWriter(new File(getScriptArgs()[0]))) {
                for (Function function : currentProgram.getFunctionManager().getFunctions(true)) {
                    String name = function.getName();
                    if (!name.equals("re_add") && !name.equals("re_score") && !name.equals("main")) continue;
                    DecompileResults result = decompiler.decompileFunction(function, 30, monitor);
                    if (!result.decompileCompleted() || result.getDecompiledFunction() == null) {
                        throw new IllegalStateException(name + ": " + result.getErrorMessage());
                    }
                    String code = result.getDecompiledFunction().getC();
                    out.println("FUNCTION " + name + " " + function.getEntryPoint());
                    out.println(code);
                    if (name.equals("re_add") && !code.contains(" + ")) {
                        throw new IllegalStateException("re_add arithmetic was not recovered");
                    }
                    found++;
                }
            }
            if (found != 3) throw new IllegalStateException("Expected three fixture functions, got " + found);
            println("REA_HEADLESS_SMOKE_OK functions=" + found);
        } finally {
            decompiler.dispose();
        }
    }
}
