# python
import sys

def hex_to_coe(hex_filename, coe_filename):
    data = []
    with open(hex_filename, 'r') as hex_file:
        for line in hex_file:
            line = line.strip()
            if not line or line[0] != ':':
                continue
            byte_count = int(line[1:3], 16)
            record_type = int(line[7:9], 16)
            # 只处理数据记录（记录类型=00）
            if record_type == 0:
                data_bytes = line[9:9+2*byte_count]
                # 按每2个字符分割
                for i in range(0, len(data_bytes), 2):
                    data.append(data_bytes[i:i+2])
    with open(coe_filename, 'w') as coe_file:
        coe_file.write("memory_initialization_radix=16;\n")
        coe_file.write("memory_initialization_vector=\n")
        coe_file.write(",".join(data))
        coe_file.write(";\n")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python hex2coe.py input.hex output.coe")
        sys.exit(1)
    hex_to_coe(sys.argv[1], sys.argv[2])