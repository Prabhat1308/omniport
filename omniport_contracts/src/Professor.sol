// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "./fhevm_libs/TFHE.sol";

contract Professor {
    
    address public admin; // to be extended to multiple admins

    constructor(address _admin) {
        admin = _admin;
    }


    modifier OnlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    struct Professor_info {
        string name;
        uint employeeNumber;
        uint subject_1_code;
        uint subject_2_code;
        uint subject_3_code;
        uint subject_4_code;
    }
    
    mapping(uint => Professor_info) public professor_info; // mapping of professor_info with employee number
    mapping(address => bool) public isProfessor;
    mapping(uint => address) public employeeNumberToAddress;

    function createProfessor(string memory _name, uint _employeeNumber, uint _subject_1_code, uint _subject_2_code, uint _subject_3_code, uint _subject_4_code) public  OnlyAdmin{
        professor_info[_employeeNumber] = Professor_info(_name, _employeeNumber, _subject_1_code, _subject_2_code, _subject_3_code, _subject_4_code);
        isProfessor[employeeNumberToAddress[_employeeNumber]] = true;
    }

    function getProfessorData(uint _employeeNumber) public view returns (string memory, uint, uint, uint, uint, uint) {
        return (professor_info[_employeeNumber].name, professor_info[_employeeNumber].employeeNumber, professor_info[_employeeNumber].subject_1_code, professor_info[_employeeNumber].subject_2_code, professor_info[_employeeNumber].subject_3_code, professor_info[_employeeNumber].subject_4_code);
    }
    

    function isProfessorEnrolledAddress(address _address) public view returns (bool) {
        return isProfessor[_address];
    }

    function isProfessorEnrolledEmployeeNumber(uint _employeeNumber) public view returns (bool) {
        return isProfessor[employeeNumberToAddress[_employeeNumber]];
    }


}