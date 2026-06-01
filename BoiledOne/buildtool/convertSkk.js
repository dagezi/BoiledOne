#!/usr/bin/env node

import * as fs from 'fs/promises';
import { createReadStream } from 'fs';

async function convertLine(line, destFile) {
    let [src, candidatesString] = line.split(' ');
    let candidates = candidatesString.split('/');

    src = src.replace(/[A-Za-z]*$/, "");
    if (!src) return;

    for (let candidate of candidates) {
        if (candidate !== "") {
            await fs.appendFile(destFile, `${src} ${candidate}\n`);
        }
    }
}

async function convertSkkDic(srcFile, destFile) {
    await fs.rm(destFile, {force: true});

    const content = await fs.readFile(srcFile, {encoding: "utf8"});
    const lines = content.split('\n');

    for await (const line of lines) {
        if (line && !line.startsWith(";")) {
            await convertLine(line, destFile);
        }
    }
}

const args = process.argv.slice(2)

convertSkkDic(args[0], args[1]);
