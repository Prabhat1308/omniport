// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "./fhevm_libs/TFHE.sol";
import "./fhe_abstracts/EIP712WithModifier.sol";

import "./Student.sol";
import "./Professor.sol";

//712 modifier to be added
contract EndsemReview is EIP712WithModifier{
 
    address public admin; // to be extended to multiple admins
    Student studentContract;
    Professor professorContract;

    constructor(address _admin , address _studentContract ,  address _professorContract) EIP712WithModifier("Authorization token", "1") {
        admin = _admin;
        studentContract = Student(_studentContract);
        professorContract = Professor(_professorContract);
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier OnlyStudent() {
        require(studentContract.isStudentEnrolledAddress(msg.sender) == true , "Only student can call this function");
        _;
    }
    
    struct Review{

        uint subject_id;
        uint Professor_id;
        euint8 professorSatisfaction; //rated from 1 to 5
        euint8 subjectSatisfaction;   //rated from 1 to 5
        euint8 courseDifficulty;      //rated from 1 to 5
        euint8 courseWorkload;        //rated from 1 to 5
        
    }

    mapping(uint => mapping (uint => Review)) public studentReviewWithSubjectsMap; // student_id to subject_id to Review
    
    
    function submitReview(uint _enrollmentNumber ,
         uint _subject_id ,
         uint _Professor_id ,
         bytes calldata encrypted_professorSatisfaction ,
         bytes calldata encrypted_subjectSatisfaction ,
         bytes calldata encrypted_courseDifficulty ,
         bytes calldata encrypted_courseWorkload
         ) public OnlyStudent {
        
        studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id] = Review(_subject_id ,
                                                                                _Professor_id , 
                                                                                TFHE.asEuint8(encrypted_professorSatisfaction) ,
                                                                                TFHE.asEuint8(encrypted_subjectSatisfaction) ,
                                                                                TFHE.asEuint8(encrypted_courseDifficulty) ,
                                                                                TFHE.asEuint8(encrypted_courseWorkload));
        }

    function getReviewWithoutEncryption(uint _enrollmentNumber ,
                       uint _subject_id 
                       ) public view  OnlyAdmin
                       returns (uint , uint , uint , uint , uint , uint) {

               return (studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].subject_id,
                       studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].Professor_id,
                       TFHE.decrypt(studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].professorSatisfaction),
                       TFHE.decrypt(studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].subjectSatisfaction),
                       TFHE.decrypt(studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].courseDifficulty),
                       TFHE.decrypt(studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].courseWorkload)
                        );
    }

    function getReviewWithEncryption(uint _enrollmentNumber ,
                       uint _subject_id 
                       ) public view 
                       returns (uint , uint , euint8 , euint8 , euint8 , euint8) {

               return (studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].subject_id,
                       studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].Professor_id,
                       studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].professorSatisfaction,
                       studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].subjectSatisfaction,
                       studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].courseDifficulty,
                       studentReviewWithSubjectsMap[_enrollmentNumber][_subject_id].courseWorkload
                        );
    }


}