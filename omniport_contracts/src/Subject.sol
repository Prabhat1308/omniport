// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "./fhevm_libs/TFHE.sol";
import "./fhe_abstracts/EIP712WithModifier.sol";
contract Subject is EIP712WithModifier{
    address public admin; // to be extended to multiple admins

    constructor(address _admin) EIP712WithModifier("Authorization token", "1"){
        admin = _admin;
    }

    struct Subject_info {
        string name;
        uint code;
        uint credits;
    }

    struct Marking {
        uint subject_code;

        //percentrages for each component expressed as x% = x
        euint8 percentage_for_assignments;
        euint8 percentage_for_quiz;
        euint8 percentage_for_midsem;
        euint8 percentage_for_endsem;
    }

    mapping(uint => Subject_info) public subject_info; // mapping of subject_info with subject code
    mapping(uint => Marking) public marking; // mapping of marking with subject code
    mapping(uint => bool) public isSubject;

    function createSubject(string memory _name, uint _code, uint _credits) public {
        subject_info[_code] = Subject_info(_name, _code, _credits);
        isSubject[_code] = true;
    }

    function assignMarkingScheme(uint _subject_code, bytes calldata _percentage_for_assignments, bytes calldata _percentage_for_quiz, bytes calldata _percentage_for_midsem, bytes calldata _percentage_for_endsem) public {
        marking[_subject_code] = Marking(_subject_code, TFHE.asEuint8(_percentage_for_assignments), TFHE.asEuint8(_percentage_for_quiz), TFHE.asEuint8(_percentage_for_midsem), TFHE.asEuint8(_percentage_for_endsem));
    }

    function getSubject(uint _subject_code) public view returns (string memory, uint, uint) {
        return (subject_info[_subject_code].name, subject_info[_subject_code].code, subject_info[_subject_code].credits);
    }
    
    function getMarking(uint _subject_code, bytes32 public_key, bytes calldata signature) public view onlySignedPublicKey(public_key, signature) returns (uint, bytes memory, bytes memory, bytes memory, bytes memory) {
        return (marking[_subject_code].subject_code,
             TFHE.reencrypt(marking[_subject_code].percentage_for_assignments, public_key, 0),
             TFHE.reencrypt(marking[_subject_code].percentage_for_quiz, public_key, 0),
             TFHE.reencrypt(marking[_subject_code].percentage_for_midsem, public_key, 0),
             TFHE.reencrypt(marking[_subject_code].percentage_for_endsem, public_key, 0)
            );
         
    }

    function getMarkingAfterReveal(uint _subject_code) public view returns (uint,uint,uint,uint,uint){
        return (
            marking[_subject_code].subject_code,
            TFHE.decrypt(marking[_subject_code].percentage_for_assignments),
            TFHE.decrypt(marking[_subject_code].percentage_for_quiz),
            TFHE.decrypt(marking[_subject_code].percentage_for_midsem),
            TFHE.decrypt(marking[_subject_code].percentage_for_endsem)
        );
    }
    
    function getMarkingWithEncryption(uint _subject_code)public view returns (euint8, euint8, euint8, euint8){
        return (
            marking[_subject_code].percentage_for_assignments,
            marking[_subject_code].percentage_for_quiz,
            marking[_subject_code].percentage_for_midsem,
            marking[_subject_code].percentage_for_endsem
        );
    }
    
    function getSubjectCredits(uint _subject_code) public view returns (uint){
        return subject_info[_subject_code].credits;
    }
    
    function isSubjectValid(uint _subject_code) public view returns (bool) {
        return isSubject[_subject_code];
    }

}