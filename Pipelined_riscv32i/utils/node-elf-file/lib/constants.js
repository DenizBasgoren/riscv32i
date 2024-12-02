const converter = {
  "create": (name, types) => {
    let encoded = {};
    let decoded = types;

    Object.keys(types).forEach((key) => {
      encoded[decoded[key]] = key;
    });

    const assure = (val, msg, def) => {
      if (val === undefined) {
        if (def !== undefined) {
          // console.warn(msg, `falling back to ${def}`);
          return def;
        }

        throw new Error(msg);
      }
      return val;
    };

    return {
      "decode": (num, def) => assure(encoded[num], `could not decode ${name} ${num}`, def),
      "encode": (type, def) => assure(decoded[type], `could not encode ${name} ${type}`, def)
    };
  }
};

const Endianness = converter.create("endianness", {
  "little": 1,
  "big": 2
});

const FileType = converter.create("file type", {
  "ET_NONE": BigInt(0x00),
  "ET_REL": BigInt(0x01),
  "ET_EXEC": BigInt(0x02),
  "ET_DYN": BigInt(0x03),
  "ET_CORE": BigInt(0x04),
  "ET_LOOS": BigInt(0xFE00),
  "ET_HIOS": BigInt(0xFEFF),
  "ET_LOPROC": BigInt(0xFF00),
  "ET_HIPROC": BigInt(0xFFFF)
});

const MachineType = converter.create("machine type", {
  "N/A": BigInt(0x00),
  "SPARC": BigInt(0x02),
  "x86": BigInt(0x03),
  "MIPS": BigInt(0x08),
  "PowerPC": BigInt(0x14),
  "S390": BigInt(0x16),
  "ARM": BigInt(0x28),
  "SuperH": BigInt(0x2A),
  "IA-64": BigInt(0x32),
  "x86-64": BigInt(0x3E),
  "AArch64": BigInt(0xB7),
  "RISC-V": BigInt(0xF3)
});

const SectionType = converter.create("section type", {
  "SHT_NULL": BigInt(0x00),
  "SHT_PROGBITS": BigInt(0x01),
  "SHT_SYMTAB": BigInt(0x02),
  "SHT_STRTAB": BigInt(0x03),
  "SHT_RELA": BigInt(0x04),
  "SHT_HASH": BigInt(0x05),
  "SHT_DYNAMIC": BigInt(0x06),
  "SHT_NOTE": BigInt(0x07),
  "SHT_NOBITS": BigInt(0x08),
  "SHT_REL": BigInt(0x09),
  "SHT_SHLIB": BigInt(0x0A),
  "SHT_DYNSYM": BigInt(0x0B),
  "SHT_INIT_ARRAY": BigInt(0x0E),
  "SHT_FINI_ARRAY": BigInt(0x0F),
  "SHT_PREINIT_ARRAY ": BigInt(0x10),
  "SHT_GROUP": BigInt(0x11),
  "SHT_SYMTAB_SHNDX": BigInt(0x12),
  "SHT_NUM": BigInt(0x13),
  "SHT_LOOS": BigInt(0x60000000),
  "SHT_GNU_ATTRIBUTES": BigInt(0x6FFFFFF5),
  "SHT_GNU_HASH": BigInt(0x6FFFFFF6),
  "SHT_VERNEED": BigInt(0x6FFFFFFE),
  "SHT_VERSYM": BigInt(0x6FFFFFFF),
  "SHT_ARM_EXIDX": BigInt(0x70000001),
  "SHT_ARM_ATTRIBUTES": BigInt(0x70000003)
});

const SectionFlag = converter.create("section flag", {
  "SHF_WRITE": BigInt(0x01),
  "SHF_ALLOC": BigInt(0x02),
  "SHF_EXECINSTR": BigInt(0x04),
  "SHF_MERGE": BigInt(0x10),
  "SHF_STRINGS": BigInt(0x20),
  "SHF_INFO_LINK": BigInt(0x40),
  "SHF_LINK_ORDER": BigInt(0x80),
  "SHF_OS_NONCONFORMING": BigInt(0x100),
  "SHF_GROUP": BigInt(0x200),
  "SHF_TLS": BigInt(0x400),
  "SHF_MASKOS": BigInt(0x0ff00000),
  "SHF_MASKPROC": BigInt(0xf0000000),
  "SHF_ORDERED": BigInt(0x4000000),
  "SHF_EXCLUDE": BigInt(0x8000000)
});

const SegmentType = converter.create("segment type", {
  "PT_NULL": BigInt(0x00),
  "PT_LOAD": BigInt(0x01),
  "PT_DYNAMIC": BigInt(0x02),
  "PT_INTERP": BigInt(0x03),
  "PT_NOTE": BigInt(0x04),
  "PT_SHLIB": BigInt(0x05),
  "PT_PHDR": BigInt(0x06),
  "PT_TLS": BigInt(0x07),
  "PT_LOOS": BigInt(0x60000000),
  "PT_GNU_EH_FRAME": BigInt(0x6474E550),
  "PT_GNU_STACK": BigInt(0x6474E551),
  "PT_GNU_RELRO": BigInt(0x6474E552),
  "PT_HIOS": BigInt(0x6FFFFFFF),
  "PT_LOPROC": BigInt(0x70000000),
  "PT_EXIDX": BigInt(0x70000001),
  "PT_HIPROC": BigInt(0x7FFFFFFF)
});

const SymbolBinding = converter.create("symbol binding", {
  "STB_LOCAL": BigInt(0x00),
  "STB_GLOBAL": BigInt(0x01),
  "STB_WEAK": BigInt(0x02),
  "STB_LOOS": BigInt(0x0A),
  "STB_HIOS": BigInt(0x0C),
  "STB_LOPROC": BigInt(0x0D),
  "STB_HIPROC": BigInt(0x0F)
});

const SymbolType = converter.create("symbol binding", {
  "STT_NOTYPE": BigInt(0x00),
  "STT_OBJECT": BigInt(0x01),
  "STT_FUNC": BigInt(0x02),
  "STT_SECTION": BigInt(0x03),
  "STT_FILE": BigInt(0x04),
  "STT_COMMON": BigInt(0x05),
  "STT_TLS": BigInt(0x06),
  "STT_LOOS": BigInt(0x0A),
  "STT_HIOS": BigInt(0x0C),
  "STT_LOPROC": BigInt(0x0D),
  // "STT_SPARC_REGISTER": BigInt(0x0D),
  "STT_HIPROC": BigInt(0x0F)
});

const SymbolVisibility = converter.create("symbol visibility", {
  "STV_DEFAULT": BigInt(0x00),
  "STV_INTERNAL": BigInt(0x01),
  "STV_HIDDEN": BigInt(0x02),
  "STV_PROTECTED": BigInt(0x03),
  "STV_EXPORTED": BigInt(0x04),
  "STV_SINGLETON": BigInt(0x05),
  "STV_ELIMINATE": BigInt(0x06)
});

const BitfieldCodec = ({ entryCodec }) => {
  return {
    "decode": (val) => {
      let flags = [];
      Array.from({ "length": 64 }, (_, bit) => {
        const entryValue = val & (BigInt(1) << BigInt(bit));
        if (entryValue > BigInt(0)) {
          flags = flags.concat([ entryCodec ? entryCodec.decode(entryValue) : entryValue ]);
        }
      });
      return flags;
    },
    "encode": (arr) => {
      let result = BigInt(0);
      arr.forEach((entry) => {
        result |= entryCodec ? entryCodec.encode(entry) : entry;
      });
      return result;
    }
  };
};

const constants = {
  Endianness,
  FileType,
  MachineType,
  SectionType,
  SectionFlag,
  SegmentType,
  BitfieldCodec,
  SymbolBinding,
  SymbolType,
  SymbolVisibility
};

module.exports= constants;
