import re, sys, json, argparse, configparser
from math import log, ceil, floor
from os import path

args = ""
config = configparser.ConfigParser()

error_msg = []
warning_msg = []
is_critical = False
br_add = 0


def radix_check(astring):
    if type(astring) != str or astring.upper() not in ['BIN', 'UNS', 'DEC', 'OCT', 'HEX']:
        raise argparse.ArgumentTypeError("Value must be one of BIN, UNS, DEC, OCT, HEX")
    return astring.upper()

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=str, help="The relative path and name (including extension) of the machine code to compile. Example 'machince_code.txt'")
    parser.add_argument("-c", "--config", type=str, default="compiler_config.ini", help="The name of the .ini config file that defines this compilers operation. Extension changing not allowed, configuration must adhere to expected format. This compiler is capable of generating its own default config file if none exists. Default filename is 'compiler_config'")
    parser.add_argument("-o", "--output", type=str, help="The name of the .mif output file. Extension changing not allowed. By default the file name has the same name as the input file, just with the .mif extension")
    parser.add_argument("-w", "--width", type=int, help="The data width of the .mif file entries. Default set in config. WARNING: Changing this value will require editing the .mif's corresponding IP Core in Quartus Prime to match. WARNING: Changing this value will yield incorrect results for Lab 5")
    parser.add_argument("-d", "--depth", type=int, help="The data depth of the .mif file (i.e. how many instructions the .mif file will have). Default set in config. WARNING: Changing this value will require editing the .mif's corresponding IP Core in Quartus Prime to match")
    # parser.add_argument("-a", "--address-radix", type=radix_check, help="The Radix used to display addresses in Quartus Prime. Accepted values are; BIN, UNS, DEC, OCT, HEX. Default set in config")
    # parser.add_argument("-t", "--data-radix", type=radix_check, help="The radix used to display data in Quartus Prime. Accepted values are; BIN, UNS, DEC, OCT, HEX. Default set in config")
    global args
    args = parser.parse_args()

def read_config():
    if not path.exists(args.config):
        check_gen()
    try:
        config.read(args.config)
        if args.width:
            config.set('General', 'DataWidth', str(args.width))
        if args.depth:
            config.set('General', 'DataDepth', str(args.depth))
        # if args.address_radix:
        #     config.set('General', 'AddressRadix', str(args.address_radix))
        # if args.data_radix:
        #     config.set('General', 'DataRadix', str(args.data_radix))
    except:
        check_gen()

def check_gen():
    print("Config file could not be read, compiler must terminate. Perhaps it is missing or contains an incorrect format. Looking for '{}'".format(args.config))        
    gen = False
    while True:
        value = input("Would you like a default config file generated before termination? (y/n): ")
        if value.lower() == "y" or value.lower() == "yes":
            gen = True
            break
        elif value.lower() == "n" or value.lower() == "no":
            break
    if gen:
        gen_default_config()

def gen_default_config():
    output = ("[General]\n\n# General settings for the compiler\n#==================================================================\n# Defines the data width of the .mif file entries. 8 by default. \n# WARNING: Changing this value will require editing the .mif's corresponding IP Core in Quartus Prime to match.\nDataWidth=8\n\n# Defines the data depth of the .mif file (i.e. how many instructions the .mif file will have). 256 by default. \n# WARNING: Changing this value will require editing the .mif's corresponding IP Core in Quartus Prime to match.\nDataDepth=256\n\n#Defines the Radix used to display addresses in Quartus Prime. Accepted values are; BIN, UNS, DEC, OCT, HEX. Set to UNS by default.\nAddressRadix=UNS\n\n# Defines the radix used to display data in Quartus Prime. Accepted values are; BIN, UNS, DEC, OCT, HEX. Set to BIN by default.\nDataRadix=BIN\n\n#==================================================================\n\n[Instructions]\n\n# Available OpCodes and rules for Instruction generation\n#==================================================================\n\n# Defines the direction to pad an Instruction should it fall short of DataWidth. Accepted values are; LEFT, RIGHT. Set to LEFT by default.\nPaddingDir=LEFT\n\n# Defines the type of padding to use should an instruction need padding. Accepted values are; PATTERN, ONES, ZEROS, SIGNED. Set to ZEROS by default.\nPaddingType=ZEROS\n\n# Defines the padding patter to use. Only used if PaddingType is PATTERN. Pattern must only contain 1 or 0. Set to 10 by default.\nPaddingPattern=10\n\n# Defines the available OpCodes for the compiler.\n# WARNING: All OpCodes must have an identically named section or the compiler will fail.\nOpCodes=BR,BRZ,ADDI,SUBI,SR0,SRH0,CLR,MOV,MOVA,MOVR,MOVRHS,PAUSE\n\n#==================================================================\n\n[BR]\n\n# Details about the BR OpCode\n#==================================================================\n\n"
    "# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,I\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=3,5\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=100\n\n# Defines whether or not the Immediate Constant, if any, in this instruction is signed\nIsSigned=True\n\n#==================================================================\n\n[BRZ]\n\n# Details about the BRZ OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,I\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=3,5\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=101\n\n# Defines whether or not the Immediate Constant, if any, in this instruction is signed\nIsSigned=True\n\n#==================================================================\n\n[ADDI]\n\n# Details about the ADDI OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,I,R\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=3,3,2\n\n# Defines "
    "the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=000\n\n# Defines whether or not the Immediate Constant, if any, in this instruction is signed\nIsSigned=True\n\n# Defines whether or not the compiler should enforce the order of the instruction after the OpCode\nForceOrder=False\n\n#==================================================================\n\n[SUBI]\n\n# Details about the SUBI OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,I,R\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=3,3,2\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=001\n\n# Defines whether or not the Immediate Constant, if any, in this instruction is signed\nIsSigned=True\n\n# Defines whether or not the compiler should enforce the order of the instruction after the OpCode\nForceOrder=False\n\n#==================================================================\n\n[SR0]\n\n# Details about the SR0 OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,I\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=4,4\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=0100\n\n# Defines whether or not the Immediate Constant, if any, in this instruction"
    " is signed\nIsSigned=False\n\n#==================================================================\n\n[SRH0]\n\n# Details about the SRH0 OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,I\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=4,4\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=0101\n\n# Defines whether or not the Immediate Constant, if any, in this instruction is signed\nIsSigned=False\n\n#==================================================================\n\n[CLR]\n\n# Details about the CLR OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,R\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=6,2\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=011000\n\n#==================================================================\n\n[MOV]\n\n# Details about the MOV OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,D,S\n\n# Defines the width of the bits in the "
    "BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=4,2,2\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=0111\n\n# Defines whether or not the compiler should enforce the order of the instruction after the OpCode\nForceOrder=True\n\n#==================================================================\n\n[MOVA]\n\n# Details about the MOVA OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,R\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=6,2\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=110000\n\n#==================================================================\n\n[MOVR]\n\n# Details about the MOVR OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,R\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=6,2\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=110001\n\n#==================================================================\n\n[MOVRHS]\n\n# Details about the MOVRHS OpCode\n#==================================================================\n\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode "
    "and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O,R\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=6,2\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=110010\n\n#==================================================================\n\n[PAUSE]\n\n# Details about the PAUSE OpCode\n#==================================================================\n# Defines the bit order of the instruction as a list separated by commas, There can only be one OpCode and it must come first. \n# Accepted values are; O (for OpCode), I (for immediate constant), R (for general register), S (for source register), D (for destination register).\nBitOrder=O\n\n# Defines the width of the bits in the BitOrder list\n# WARNING: Total instruction width CANNOT exceed DataWidth\nBitWidth=8\n\n# Defines the OpCode as a set of bits\n# WARNING: The width of the Opcode must match the width defined in the BitWidth list\nOpCode=11111111\n\n#=================================================================="
    )

    file = open("compiler_config.ini", "w")
    file.write(output)
    file.close()
    sys.exit()


def bindigits(n, bits, signed, linenum):
    #print("BinDigits:")
    #print(n, bits, signed)
    limit = 0
    if n > 0 and signed:
        #print("n > 0 and signed")
        limit = ceil( ( log(n + 1) / log(2) ) + 1 )
    elif n < 0 and signed:
        #print("n < 0 and signed")
        limit = ceil( ( log(-n) / log(2) ) + 1 )
    elif n < 0 and not signed:
        #print("n < 0 and unsigned")
        error_msg.append("Error on line {}: Attempted binary number conversion for unsigned int {}. This OpCode does not support signed numbers".format(linenum, n))
        is_critical = True
        return False, False
    elif n > 0 and not signed:
        #print("n > 0 and unsigned")
        limit = ceil( log(n + 1) / log(2) )
    
    #print("limit:", limit)

    if limit > bits:
        if signed:
            error_msg.append("Error on line {}: Attempted binary number conversion for signed int {} is outside the {}-bit limit for this OpCode.".format(linenum, n, bits))
            return False, limit
        else:
            error_msg.append("Error on line {}: Attempted binary number conversion for unsigned int {} is outside the {}-bit limit for this OpCode.".format(linenum, n, bits))
            return False, limit

    s = bin(n & int("1"*bits, 2))[2:]
    bin_num = ("{0:0>%s}" % (bits)).format(s)
    return True, bin_num


def split_string(line):
    #print(line)
    entries = re.split(';|,| |, |; |\n', line)
    entries = [s for s in entries if s]
    #print(entries)

    return entries

def print_msg(text, type):
    OKGREEN = ' \033[92m '                                                            
    OKBLUE = ' \033[94m '                                                             
    ENDC = ' \033[0m '                                                                
    BOLD = " \033[1m "                                                                
                                                                                
    HEADER = ' \033[95m '                                                             
    WARNING = ' \033[93m '                                                            
    FAIL = ' \033[91m '

    if type == 'WARN':
        print('\t' + WARNING + text + ENDC + '\n') 
    elif type == 'ERROR':
         print('\t' + FAIL + text + ENDC + '\n')
    elif type == 'COMP_S':
        print('\t' + BOLD + OKGREEN + text + ENDC + '\n') 
    elif type == 'COMP_W':
        print('\t' + BOLD + OKBLUE + text + ENDC + '\n') 
    elif type == 'COMP_E':
        print('\t' + BOLD + FAIL + text + ENDC + '\n') 

def print_all_msgs():

    if is_critical:
        error_msg.append("One or more critical errors occured while compiling. Cannot generate output code!")

    for warning in warning_msg:
        print_msg(warning, 'WARN') 

    for error in error_msg:
        print_msg(error, 'ERROR')


def gen_output(opcodes):
    if is_critical:
        return
    
    lines = [
        '-- Copyright (C) 2017  Intel Corporation. All rights reserved. \n',
        '-- Your use of Intel Corporation\'s design tools, logic functions \n',
        '-- and other software and tools, and its AMPP partner logic \n',
        '-- functions, and any output files from any of the foregoing \n',
        '-- (including device programming or simulation files), and any \n',
        '-- associated documentation or information are expressly subject \n',
        '-- to the terms and conditions of the Intel Program License \n',
        '-- Subscription Agreement, the Intel Quartus Prime License Agreement, \n',
        '-- the Intel FPGA IP License Agreement, or other applicable license \n',
        '-- agreement, including, without limitation, that your use is for \n',
        '-- the sole purpose of programming logic devices manufactured by \n',
        '-- Intel and sold by Intel or its authorized distributors.  Please \n',
        '-- refer to the applicable agreement for further details. \n',
        '\n',
        '-- Custom Python generated Memory Initialization File (.mif) \n',
        '\n',
    ]

    lines.append('WIDTH={};\n'.format(config.getint('General', 'DataWidth')))
    lines.append('')
    lines.append('DEPTH={};\n'.format(config.getint('General', 'DataDepth')))
    lines.append('\n')
    lines.append('ADDRESS_RADIX={};\n'.format(config.get('General', 'AddressRadix')))
    lines.append('DATA_RADIX={};\n'.format(config.get('General', 'DataRadix')))
    lines.append('\n')

    lines.append('CONTENT BEGIN\n')

    for index, entry in enumerate(opcodes):
        lines.append('\t{}\t:\t{};\n'.format(index, entry))
    
    if len(opcodes) < config.getint('General', 'DataDepth')-1:
        lines.append('\t[{}..{}]\t:\t{};\n'.format(len(opcodes), config.getint('General', 'DataDepth')-1, '0'*config.getint('General', 'DataWidth')))
    lines.append('END;\n')

    filename = ""
    if args.output:
        filename = args.output.split(".")[0]
    else:
        filename = args.file.split(".")[0]
    filename += ".mif"

    f = open(filename, "w")
    f.writelines(lines)
    f.close()

    if not error_msg:
        if not warning_msg:
            print_msg("Memory Initialization File Successfully Generated!\n\t\tOuput File Name '{}'".format(filename), 'COMP_S')
        else:
            print_msg("Memory Initialization File Successfully Generated With WARNINGS. This Code May Not Function As Intended!\n\t\tOuput File Name '{}'".format(filename), 'COMP_W')
    else:
        print_msg("Memory Initialization File Successfully Generated With ERRORS. This Code Likely Will Not Function As Intended!\n\t\tOuput File Name '{}'".format(filename), 'COMP_E')


def process_line(line, line_num):
    result = ""

    supported_opcodes = config.get('Instructions', 'OpCodes').split(',')
    supported_opcodes = [s.replace(" ", "") for s in supported_opcodes]

    opcode = line[0].upper()
    line = line[1:]

    if opcode not in supported_opcodes:
        error_msg.append("Error on line {}: OpCode {} is not a supported OpCode. For a list of supported OpCodes check the config file".format(line_num, opcode))
        is_critical = True
        return

    bit_order = config.get(opcode, 'BitOrder').split(',')
    bit_order = [s.replace(" ", "") for s in bit_order]

    num_ops = len(bit_order)

    bit_width = config.get(opcode, 'BitWidth').split(',')
    bit_width = [int(s.replace(" ", "")) for s in bit_width]

    total_bit_width = 0
    for bits in bit_width:
        total_bit_width += bits

    bit_opcode = config.get(opcode, 'OpCode')
    result += bit_opcode

    if len(bit_opcode) != bit_width[0]:
        error_msg.append("Error on line {}: Opcode length specified in config files do not match. BitOrder[0] must be 'O', BitWidth[0] must be the same length as OpCode. Fix the config file!".format(line_num))
        is_critical = True
        return

    is_signed = False
    if config.has_option(opcode, 'IsSigned'):
        is_signed = config.getboolean(opcode, 'IsSigned')

    force_order = False
    if config.has_option(opcode, 'ForceOrder'):
        force_order = config.getboolean(opcode, 'ForceOrder')

    compound_immediate = False
    if config.has_option(opcode, 'CompoundImmediate'):
        compound_immediate = config.getboolean(opcode, 'CompoundImmediate')

    branch_aware = False
    if config.has_option(opcode, 'BranchAware'):
        branch_aware = config.getboolean(opcode, 'BranchAware')

    if len(line) != num_ops - 1:
        error_msg.append("Error on line {}: OpCode {} has mismatched operators. Expected {}, got {}".format(line_num, opcode, num_ops, len(line)))
        is_critical = True
        return

    if force_order:
        #Specific Order Required
        for index, op in enumerate(line):
            if op[0].lower() == 'r':
                if bit_order[index+1] == 'R' or bit_order[index+1] == 'S' or bit_order[index+1] == 'D':
                    regID = int(op[1:])
                    bin_res = bindigits(regID, bit_width[index+1], False, line_num)
                    if bin_res[0] == True:                        
                        result += bin_res[1]
                    else:
                        is_critical = True
                        return
                else:
                    error_msg.append("Error on line {}: Operator order does not match expected order. Operator order is enforced for this instruction. For the correct operator order check the config file".format(line_num))
                    is_critical = True
                    return
            elif op[0] == '#':
                if bit_order[index+1] == 'I':
                    imm = int(op[1:])
                    bin_res = bindigits(imm, bit_width[index+1], is_signed, line_num)
                    if bin_res[0] == True:
                        result += bin_res[1]
                    else:
                        is_critical = True
                        return
                else:
                    error_msg.append("Error on line {}: Operator order does not match expected order. Operator order is enforced for this instruction. For the correct operator order check the config file".format(line_num))
                    is_critical = True
                    return
            else:
                inferred = ""
                width = bit_width[index+1]
                val = ""
                if bit_order[index+1] == 'R':
                    inferred = "Register"
                    bin_res = bindigits(int(op), width, False, line_num)
                    if bin_res[0]:
                        val = bin_res[1]
                    else:
                        is_critical = True
                        return
                elif bit_order[index+1] == 'S':
                    inferred = "Source Register"
                    bin_res = bindigits(int(op), width, False, line_num)
                    if bin_res[0]:
                        val = bin_res[1]
                    else:
                        is_critical = True
                        return
                elif bit_order[index+1] == 'D':
                    inferred = "Destination Register"
                    bin_res = bindigits(int(op), width, False, line_num)
                    if bin_res[0]:
                        val = bin_res[1]
                    else:
                        is_critical = True
                        return
                elif bit_order[index+1] == 'I':
                    inferred = "Immediate Constant"
                    bin_res = bindigits(int(op), width, is_signed, line_num)
                    if bin_res[0]:
                        val = bin_res[1]
                    else:
                        is_critical = True
                        return
                warning_msg.append("Warning on line {}: Operator Value '{}' missing identifier. Inferring as {}".format(line_num, op, inferred))
                result += val

    else:
        #General Order Accepted
        op_order = []
        op_value = []
        to_infer = []
        for index, op in enumerate(line):
            if op[0].lower() == 'r':
                op_order.append('R')
                op_value.append(op[1:])
            elif op[0].lower() == '#':
                op_order.append('I')
                op_value.append(op[1:])
            else:
                op_order.append('')
                op_value.append(op)
                to_infer.append(index)

        req_reg = bit_order.count('R') + bit_order.count('S') + bit_order.count('D')
        req_imm = bit_order.count('I')

        act_reg = op_order.count('R')
        act_imm = op_order.count('I')

        for index in to_infer:
            if act_reg < req_reg:
                op_order[index] = 'R'
                warning_msg.append("Warning on line {}: Operator Value '{}' missing identifier. Inferring as Register".format(line_num, op_value[index]))
                act_reg += 1
            elif act_imm < req_imm:
                op_order[index] = 'I'
                warning_msg.append("Warning on line {}: Operator Value '{}' missing identifier. Inferring as Immediate Constant".format(line_num, op_value[index]))
                act_imm += 1

        reg_list = []
        imm_list = []

        for index, op in enumerate(op_order):
            if op == 'R':
                reg_list.append(op_value[index])
            elif op == 'I':
                imm_list.append(op_value[index])
        
        for index, op in enumerate(bit_order):
            if op == 'R' or op == 'S' or op == 'D':
                val = reg_list.pop(0)
                bin_res = bindigits(int(val), bit_width[index], False, line_num)
                if bin_res[0]:
                    val = bin_res[1]
                else:
                    is_critical = True
                    return
                result += val
            elif op == 'I':
                val = imm_list.pop(0)
                bin_res = bindigits(int(val), bit_width[index], is_signed, line_num)
                if bin_res[0]:
                    val = bin_res[1]
                else:
                    is_critical = True
                    return
                result += val

    #Padding Check
    diff = config.getint('General', 'DataWidth') - total_bit_width
    pad_dir = config.get('Instructions', 'PaddingDir')
    pad_type = config.get('Instructions', 'PaddingType')
    if diff > 0:
        while (diff > 0):
            to_pad = ""
            if pad_type == 'PATTERN':
                to_pad = config.get('Instructions', 'PaddingPattern')
                if len(to_pad) > diff:
                    if diff > 1:
                        to_pad = to_pad[0:diff - 1]
                    else:
                        to_pad = to_pad[0]
            elif pad_type == 'ONES':
                to_pad = '1'
            elif pad_type == 'ZEROS':
                to_pad = '0'
            elif pad_type == 'SIGNED':
                if pad_dir == 'LEFT':
                    to_pad = result[0]
                elif pad_dir == 'RIGHT':
                    to_pad = result[-1]
                else:
                    error_msg.append("Unsupported PaddingDir in config file. Fix the config")
                    is_critical = True
                    return 
            else:
                error_msg.append("Unsupported PaddingType in config file. Fix the config")
                is_critical = True
                return
            if pad_dir == 'LEFT':
                result = to_pad + result
            elif pad_dir == 'RIGHT':
                result = result + to_pad
            else:
                error_msg.append("Unsupported PaddingDir in config file. Fix the config")
                is_critical = True
                return 
            diff -= len(to_pad)

    return result


def compile_file():
    if not path.exists(args.file):
        print_msg("Code file '{}' not found. Terminating!".format(args.file), 'ERROR')
        sys.exit()

    file = open(args.file, "r")
    lines = []
    output = []
    supported_opcodes = config.get('Instructions', 'OpCodes').split(',')
    supported_opcodes = [s.replace(" ", "") for s in supported_opcodes]

    index = 1
    while (True):

        line = file.readline()
        if not line:
            break
        line = line.split(';', 1)[0]

        num_ops = 0
        for op in supported_opcodes:
            num_ops += line.count(op + " ")
        
        if num_ops > 1:
            error_msg.append("Error on line {}: Cannot have more than one instruction per line".format(index))
            is_critical = True
        if num_ops == 0 and 'PAUSE' not in line:
            line = []
        lines.append(line)
        index += 1

    # print(lines)

    for index, line in enumerate(lines):
        if not line:
            continue
        split = split_string(line)
        res = process_line(split, index+1)
        output.append(res)

    return output


if __name__ == '__main__':    
    parse_args()    
    read_config()
    output = compile_file()
    print_all_msgs()
    gen_output(output)