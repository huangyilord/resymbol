//
//  main.m
//  resymbol
//
//  Created by Yi Huang on 9/8/15.
//  Copyright (c) 2015 huangyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach-o/loader.h>

typedef struct macho_header
{
    uint32_t	magic;		/* mach magic number identifier */
    cpu_type_t	cputype;	/* cpu specifier */
    cpu_subtype_t	cpusubtype;	/* machine specifier */
    uint32_t	filetype;	/* type of file */
    uint32_t	ncmds;		/* number of load commands */
    uint32_t	sizeofcmds;	/* the size of all the load commands */
    uint32_t	flags;		/* flags */
} macho_header;

typedef struct macho_header64
{
    uint32_t	magic;		/* mach magic number identifier */
    cpu_type_t	cputype;	/* cpu specifier */
    cpu_subtype_t	cpusubtype;	/* machine specifier */
    uint32_t	filetype;	/* type of file */
    uint32_t	ncmds;		/* number of load commands */
    uint32_t	sizeofcmds;	/* the size of all the load commands */
    uint32_t	flags;		/* flags */
    uint32_t reserved;
} macho_header64;

typedef struct macho_load_command
{
    uint32_t cmd;
    uint32_t cmdsize;
} macho_load_command;

typedef struct macho_segment_command
{
    uint32_t cmd;
    uint32_t cmdsize;
    char segname[16];
    uint32_t vmaddr;
    uint32_t vmsize;
    uint32_t fileoff;
    uint32_t filesize;
    vm_prot_t maxprot;
    vm_prot_t initprot;
    uint32_t nsects;
    uint32_t flags;
} macho_segment_command;

typedef struct macho_symtab_command
{
    uint32_t cmd;
    uint32_t cmdsize;
    uint32_t symoff;
    uint32_t nsyms;
    uint32_t stroff;
    uint32_t strsize;
} macho_symtab_command;

typedef struct macho_section
{
    char sectname[16];
    char segname[16];
    uint32_t addr;
    uint32_t size;
    uint32_t offset;
    uint32_t align;
    uint32_t reloff;
    uint32_t nreloc;
    uint32_t flags;
    uint32_t reserved1;
    uint32_t reserved2;
} macho_section;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if ( argc < 4 )
        {
            return -1;
        }
        NSString* elfFileName = [NSString stringWithUTF8String:argv[1]];
        NSString* fromSymbol = [NSString stringWithUTF8String:argv[2]];
        NSString* toSymbol = [NSString stringWithUTF8String:argv[3]];

        NSUInteger offset = 0;
        struct macho_header header = { 0 };
        NSMutableData* fileContent = [NSMutableData dataWithContentsOfFile:elfFileName];
        [fileContent getBytes:&header range: NSMakeRange(offset, sizeof(macho_header)) ];
        if ( header.magic == MH_MAGIC_64 || header.magic == MH_CIGAM_64 )
        {
            offset += sizeof(macho_header64);
        }
        else
        {
            offset += sizeof(macho_header);
        }
        BOOL bGenerateNewFile = NO;
        for ( uint32_t i = 0; i < header.ncmds; ++i )
        {
            macho_load_command cmd = { 0 };
            [fileContent getBytes:&cmd range: NSMakeRange(offset, sizeof(macho_load_command))];
            if ( LC_SYMTAB == cmd.cmd )
            {
                macho_symtab_command symtabcommand = {0};
                [fileContent getBytes:&symtabcommand range: NSMakeRange(offset, sizeof(macho_symtab_command))];
                char* stringData = malloc(symtabcommand.strsize);
                [fileContent getBytes:stringData range: NSMakeRange(symtabcommand.stroff, symtabcommand.strsize)];
                uint32_t offset = 0;
                BOOL bReplace = NO;
                while ( offset < symtabcommand.strsize )
                {
                    char* str = stringData + offset;
                    size_t len = strlen(str);
                    if ( len > 0 && memcmp( [fromSymbol UTF8String], str, len ) == 0 )
                    {
                        bReplace = YES;
                        memcpy( str, [toSymbol UTF8String], len );
                    }
                    offset += len + 1;
                }
                if ( bReplace )
                {
                    [fileContent replaceBytesInRange:NSMakeRange(symtabcommand.stroff, symtabcommand.strsize) withBytes:stringData];
                    bGenerateNewFile = YES;
                }
                free( stringData );
            }
            offset += cmd.cmdsize;
        }
        if ( bGenerateNewFile )
        {
            NSString* targetName = [NSString stringWithFormat:@"%@.r", elfFileName];
            [fileContent writeToFile:targetName atomically:YES];
        }
    }
    return 0;
}
