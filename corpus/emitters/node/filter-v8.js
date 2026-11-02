// filter-v8.js DIR OUT: keep only the sample's own scripts from the one NODE_V8_COVERAGE file in DIR.
const fs = require("fs");
const [dir, out] = process.argv.slice(2);
const files = fs.readdirSync(dir);
if (files.length !== 1) throw new Error(`expected one coverage file in ${dir}, found ${files.length}`);
const data = JSON.parse(fs.readFileSync(`${dir}/${files[0]}`, "utf8"));
data.result = data.result.filter((r) => r.url.startsWith("file:///work/") && !r.url.includes("node_modules"));
fs.writeFileSync(out, JSON.stringify(data, null, 1) + "\n");
