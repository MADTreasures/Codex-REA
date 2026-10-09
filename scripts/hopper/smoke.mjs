import assert from 'node:assert/strict';
import { writeFile } from 'node:fs/promises';
import { parseConfig } from '/opt/rea/dist/config.js';
import { createBinarySession } from '/opt/rea/dist/composition/binary.js';
import { createLogger } from '/opt/rea/dist/logger.js';
const parsed = parseConfig(process.env);
assert.ok(parsed.ok);
const session = createBinarySession(parsed.value, createLogger('hopper-smoke', 'warn'));
const controller = new AbortController();
const timer = setTimeout(() => controller.abort(), 45000);
const results = {};
try {
    results.open = await session.open('/work/harmless.elf', { providerId: 'hopper', signal: controller.signal });
    assert.ok(results.open.ok);
    for (const [operation, parameters] of [
        ['current_document', {}], ['list_procedures', {}],
        ['procedure_assembly', { procedure: 'demo_add' }],
        ['procedure_pseudo_code', { procedure: 'demo_add' }],
    ]) {
        results[operation] = await session.execute(operation, parameters, { signal: controller.signal });
        assert.ok(results[operation].ok, operation);
        assert.equal(results[operation].value.provider.id, 'hopper');
    }
    const names = JSON.stringify(results.list_procedures.value.result);
    for (const name of ['main', 'demo_add', 'demo_check']) assert.ok(names.includes(name));
    assert.match(JSON.stringify(results.procedure_assembly.value.result), /add/);
    await new Promise(resolve => setTimeout(resolve, 10000));
    results.documentAfterWait = await session.execute('current_document', {}, { signal: controller.signal });
    assert.ok(results.documentAfterWait.ok);
    assert.equal(results.documentAfterWait.value.result, results.current_document.value.result);
    results.success = true;
    console.log('PASS: Hopper ELF document, bridge, functions, assembly, pseudocode and 10-second responsiveness');
} catch (error) {
    results.success = false;
    results.failure = String(error);
    process.exitCode = 1;
    console.error(error);
} finally {
    clearTimeout(timer);
    await session.close();
    await writeFile('/work/smoke-results.json', JSON.stringify(results, null, 2));
}
