#include <iostream>
#include <algorithm>
#include <fstream>
#include <string>
#include <bitset>
#include <cctype>
#include <unordered_map>



// Helper function to convert integer to binary
std::string intToBinary(const std::string& intStr, int numBits) {
    // Convert string to int
    int num;
    try {
        num = std::stoi(intStr);
    }
    catch (const std::exception& e) {
        throw std::invalid_argument("Invalid integer string");
    }

    // Check if numBits is valid
    if (numBits <= 0 || numBits > 32) {
        throw std::invalid_argument("Number of bits must be between 1 and 32");
    }

    // Convert to binary using bitset
    std::bitset<32> bits(num);

    // Get the binary string and take the last numBits
    std::string binaryStr = bits.to_string();
    return binaryStr.substr(32 - numBits);
}


int main(void)
{
	std::ifstream inpf{ "assembly_instructions.txt" };
	std::ofstream outpf{ "instructions.txt" };

    std::unordered_map<std::string, std::string> r4_type_opcodes =
    {
        {"smaddl", "10000"},
        {"smaddh", "10001"},
        {"smsubl", "10010"},
        {"smsubh", "10011"},
        {"lmaddl", "10100"},
        {"lmaddh", "10101"},
        {"lmsubl", "10110"},
        {"lmsubh", "10111"}
    };

    std::unordered_map<std::string, std::string> r3_type_opcodes =
    {
        {"slhi", "1100000001"},
        {"au", "1100000010"},
        {"cnt1h", "1100000011"},
        {"ahs", "1100000100"},
        {"and", "1100000101"},
        {"bcw", "1100000110"},
        {"maxws", "1100000111"},
        {"minws", "1100001000"},
        {"mlhu", "1100001001"},
        {"mlhcu", "1100001010"},
        {"or", "1100001011"},
        {"clzh", "1100001100"},
        {"rlh", "1100001101"},
        {"sfwu", "1100001110"},
        {"sfhs", "1100001111"}
    };

    if (!inpf)
    {
        // Print an error and exit
        std::cerr << "Uh oh, assembly_instructions.txt could not be opened for writing!\n";
        return 1;
    }

    if (!outpf)
    {
        // Print an error and exit
        std::cerr << "Uh oh, instructions.txt could not be opened for writing!\n";
        return 1;
    }

    std::string instruction;
    std::string output;
    std::string operation;
    while (std::getline(inpf, instruction))
    {
        output = "";
        operation = "";
        int i = 0;
        while (instruction[i] != ' ' && instruction[i] != '\0')
        {
            operation += instruction[i++];
        }

        std::cout << "operation: " << operation << '\n';

        // Convert to lower case
        std::transform(operation.begin(), operation.end(), operation.begin(),
            [](unsigned char c) { return std::tolower(c); });

        // Check if load type
        if (operation == "ldi")
        {
            output += "0";

            std::string destination_reg, load_index, immediate;

            // Get destination_reg
            while (instruction[i] != ',')
                destination_reg += instruction[i++];
            i++;

            // Get load_index
            while (instruction[i] != ',')
                load_index += instruction[i++];
            i++;

            // Get immediate
            while (instruction[i] != '\0')
                immediate += instruction[i++];

            output += intToBinary(load_index, 3) + intToBinary(immediate, 16) + intToBinary(destination_reg, 5);

        }

        // Check if r4 instruction
        else if (r4_type_opcodes.find(operation) != r4_type_opcodes.end())
        {
            // Get r4 opcode
            output += r4_type_opcodes[operation];
            std::string destination_reg, rs3, rs2, rs1;

            // Get destination_reg
            while (instruction[i] != ',')
                destination_reg += instruction[i++];
            i++;

            // Get rs3
            while (instruction[i] != ',')
                rs3 += instruction[i++];
            i++;

            // Get rs2
            while (instruction[i] != ',')
                rs2 += instruction[i++];
            i++;

            // Get rs1
            while (instruction[i] != '\0')
                rs1 += instruction[i++];

            output += intToBinary(rs3, 5) + intToBinary(rs2, 5) + intToBinary(rs1, 5) + intToBinary(destination_reg, 5);
        }

        // Check if r3 instruction
        else if (r3_type_opcodes.find(operation) != r3_type_opcodes.end())
        {
            // Get r3 opcode
            output += r3_type_opcodes[operation];
            std::string destination_reg, rs2, rs1;

            // Get destination_reg
            while (instruction[i] != ',')
                destination_reg += instruction[i++];
            i++;
          
            // Get rs2
            while (instruction[i] != ',')
                rs2 += instruction[i++];
            i++;

            // Get rs1
            while (instruction[i] != '\0')
                rs1 += instruction[i++];

            output += intToBinary(rs2, 5) + intToBinary(rs1, 5) + intToBinary(destination_reg, 5);
        }

        // Else, we have nop
        else
        {
            output = "1100000000000000000000000";
        }

        outpf << output << '\n';
    } // End of file reading
} // End of main