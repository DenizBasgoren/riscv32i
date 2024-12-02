const fs = require('fs');
let process = require('process')
let elf = require('./node-elf-file/lib/index.js')

let RED_COLOR = '\x1b[31m%s\x1b[0m'
let GREEN_COLOR = '\x1b[32m%s\x1b[0m'
let GOLDEN_COLOR = '\x1b[38;5;214m%s\x1b[0m'

if (process.argv.length < 3) {
	console.error('Usage: node prepareInstructions.js sampleProgram.elf')
	process.exit(1)
}

let fileContents

fileContents = fs.readFileSync(process.argv[2])


let bufferToVerilogHex = buffer => {
	return Array.from(buffer, byte => byte.toString(16).padStart(2, '0')).join(' ')
}

let parsed = elf.parse(fileContents)
let analyzed = elf.analyze(parsed)

global.textSection = analyzed.sections['.text']
if (textSection) {
	global.textBuffer = Buffer.alloc(Number(textSection.address) + Number(textSection.size))
	analyzed.chunks[Number(textSection.chunk_idx)].data.copy(textBuffer, Number(textSection.address), Number(textSection.chunk_offset), Number(textSection.chunk_offset) + Number(textSection.size))
	fs.writeFileSync(process.argv[2] + '.imem', bufferToVerilogHex(textBuffer))
	console.log(GREEN_COLOR, `Prepared the instructions in file ${process.argv[2] + '.imem'}`)
	console.log(GOLDEN_COLOR, `Note: INSTMEM_LENGTH must be at least ${textBuffer.length > 200 ? textBuffer.length : 200}!`)
}


let sections = []

for (const key in analyzed.sections) {
	if (/\.(rodata|data|bss)\.?/.test(key)) {
		sections.push(analyzed.sections[key])
	}
}

if (sections.length > 0) {
	global.dmemBuffer = Buffer.alloc(Math.max(...sections.map(s => Number(s.address) + Number(s.size))))

	sections.forEach(s => {
		analyzed.chunks[Number(s.chunk_idx)].data.copy(dmemBuffer, Number(s.address), Number(s.chunk_offset), Number(s.chunk_offset) + Number(s.size))
	})

	fs.writeFileSync(process.argv[2] + '.dmem', bufferToVerilogHex(dmemBuffer))
	console.log(GREEN_COLOR, `Prepared the data in file ${process.argv[2] + '.dmem'}`)
	console.log(GOLDEN_COLOR, `Note: DATAMEM_LENGTH must be at least ${dmemBuffer.length+500}!`)
	// the 500 here is for the stack
}

let symtabSection = analyzed.sections['.symtab']
if (symtabSection) {
	for (let i = 0; i < symtabSection.symbols.length; i++) {
		let sym = symtabSection.symbols[i]
		if (sym.name == '_start') {
			console.log(GOLDEN_COLOR, `Note: INITIAL_PC_ADDRESS must be ${Number(sym.value)}`)
			break
		}
	}
}
else {
	console.log(RED_COLOR, '_start not found')
}





