// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "./fhevm_libs/TFHE.sol";
import "./fhe_abstracts/EIP712WithModifier.sol";

contract Student is EIP712WithModifier{
    address public admin; // to be extended to multiple admins

    constructor(address _admin) EIP712WithModifier("Authorization token", "1"){
        admin = _admin;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    modifier OnlyStudent() {
        require(isStudent[msg.sender] == true , "Only student can call this function");
        _;
    }

    struct Student_info {
        string name;
        uint enrollmentNumber;
        uint semester;
        euint8 cgpa;
        uint subject_1_code;
        uint subject_2_code;
        uint subject_3_code;
        uint subject_4_code;
    }

    mapping(uint => Student_info) public student_info; // mapping of student_info with enrollment number
    mapping(address => bool) public isStudent;
    mapping(uint => address) public enrollmentNumberToAddress;

    function createStudent(
        string memory _name,
        uint _enrollmentNumber,
        uint _semester,
       // bytes calldata _cgpa,
        uint _subject_1_code,
        uint _subject_2_code,
        uint _subject_3_code,
        uint _subject_4_code
    ) public OnlyAdmin {
        student_info[_enrollmentNumber] = Student_info(
            _name,
            _enrollmentNumber,
            _semester,
            TFHE.asEuint8(0),
            _subject_1_code,
            _subject_2_code,
            _subject_3_code,
            _subject_4_code
        );
        isStudent[enrollmentNumberToAddress[_enrollmentNumber]] = true;
    }

    function getStudentData(
        uint _enrollmentNumber 
      
    )   public view returns (string memory, uint, uint, euint8, uint, uint, uint, uint)
    {
        return (
            student_info[_enrollmentNumber].name,
            student_info[_enrollmentNumber].enrollmentNumber,
            student_info[_enrollmentNumber].semester,
            student_info[_enrollmentNumber].cgpa,
            student_info[_enrollmentNumber].subject_1_code,
            student_info[_enrollmentNumber].subject_2_code,
            student_info[_enrollmentNumber].subject_3_code,
            student_info[_enrollmentNumber].subject_4_code
        );
    }

    
    function changeCGPA (euint8 CGPA, uint _enrollmentNumber) public{ //visibility to be corrected
       student_info[_enrollmentNumber].cgpa = CGPA;
    }
    
    //TO be able to view CGPA during the period between endsem and grade calculation
    function viewCGPA(uint _enrollmentNumber , bytes32 public_key , bytes calldata signature) public view OnlyStudent onlySignedPublicKey(public_key, signature)returns (bytes memory){
        return TFHE.reencrypt(student_info[_enrollmentNumber].cgpa, public_key , 0);
    }

    function isStudentEnrolled(uint _enrollmentNumber) public view returns (bool) {
        return isStudent[enrollmentNumberToAddress[_enrollmentNumber]];
    }

    function isStudentEnrolledAddress(address _address) public view returns (bool) {
        return isStudent[_address];
    }
}
