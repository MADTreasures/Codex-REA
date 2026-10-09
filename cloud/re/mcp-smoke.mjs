import assert from "node:assert/strict";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const [target, output] = process.argv.slice(2);
assert(target && output, "Usage: node mcp-smoke.mjs ABSOLUTE_ELF OUTPUT_DIR");
const prefix = process.env.REA_CLOUD_REA_PREFIX ?? "/workspace/.rea-cli";
const sdk = join(prefix, "lib/node_modules/rea-agents/node_modules/@modelcontextprotocol/client/dist");
const { Client } = await import(pathToFileURL(join(sdk, "index.mjs")));
const { StdioClientTransport } = await import(pathToFileURL(join(sdk, "stdio.mjs")));
const scriptDir = dirname(fileURLToPath(import.meta.url));
await mkdir(output, { recursive: true });
const client = new Client({ name: "rea-ghidra-cloud-smoke", version: "1.0.0" });
const transport = new StdioClientTransport({
  command: join(scriptDir, "start-rea.sh"), args: ["mcp"], cwd: scriptDir, stderr: "pipe",
});
let stderr = "";
transport.stderr?.on("data", (chunk) => { stderr += chunk.toString(); });

function evidence(value, operation) {
  if (value && typeof value === "object") {
    if (value.operation === operation && "normalized_result" in value) return value;
    for (const child of Object.values(value)) {
      const match = evidence(child, operation);
      if (match) return match;
    }
  }
  if (typeof value === "string") {
    try { return evidence(JSON.parse(value), operation); } catch { return undefined; }
  }
}

async function call(name, args) {
  const start = performance.now();
  const result = await client.callTool({ name, arguments: args }, undefined, { timeout: 360000 });
  await writeFile(join(output, `${name}.json`), JSON.stringify(result, null, 2) + "\n");
  assert(!result.isError, `${name}: ${JSON.stringify(result).slice(0, 1000)}`);
  console.log(`${name}: ok (${((performance.now() - start) / 1000).toFixed(3)} s)`);
  return result;
}

try {
  await client.connect(transport);
  assert.equal(client.getServerVersion().version, "6.1.0");
  await call("open_binary", { path: resolve(target), provider_id: "ghidra" });
  const search = evidence(await call("search_procedures", { pattern: "re_" }), "search_procedures");
  assert.equal(search.provider.id, "ghidra");
  assert.equal(search.provider.version, "12.1.4");
  const add = search.normalized_result.find((item) => item.value === "re_add");
  assert(add, "re_add must be recovered");
  const fn = evidence(await call("analyze_function", { procedure: "re_add" }), "analyze_function");
  assert(fn.normalized_result.assembly.length > 0);
  assert(fn.normalized_result.pseudocode.includes("return right + left;"));
  const batch = await call("batch_decompile", { addresses: [add.address] });
  assert(JSON.stringify(batch).includes("return right + left;"));
  await call("close_binary", {});
  console.log("REA_GHIDRA_MCP_SMOKE_OK");
} finally {
  await client.close();
  await writeFile(join(output, "mcp.stderr"), stderr);
}
