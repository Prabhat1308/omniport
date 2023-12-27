// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "./fhevm_libs/TFHE.sol";

import "./Student.sol";
import "./Professor.sol";
import "./Subject.sol";

//712 modifier to be added

contract GradeCalc {
    
    address public admin; // to be extended to multiple admins  
    Professor professorContract;
    Subject subjectContract;
    Student studentContract;
    
   
    mapping(uint => mapping ( uint => euint8)) public studentGradeWithSubjectsMap; // student_id to subject_id to marks

    constructor(address _admin , address _professorContract , address _subjectContract , address _studentContract) {
        admin = _admin;
        professorContract = Professor(_professorContract);
        subjectContract = Subject(_subjectContract);
        studentContract = Student(_studentContract);
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier OnlyProfessor() {
        require(professorContract.isProfessorEnrolledAddress(msg.sender) == true , "Only professor can call this function");
        _;
    }

    function calculateGrade(uint _enrollmentNumber ,
         uint _subject_id ,
         bytes calldata encrypted_assignment_marks,
        bytes calldata encrypted_quiz_marks,
        bytes calldata encrypted_midsem_marks,
        bytes calldata encrypted_endsem_marks) 
        public OnlyProfessor 
      {
     (euint8 percentage_for_assignment ,euint8 percentage_for_quiz , euint8 percentage_for_midsem , euint8 percentage_for_endsem ) = subjectContract.getMarkingWithEncryption(_subject_id ); 
      
     euint8 assigment_contri = TFHE.mul(percentage_for_assignment ,TFHE.asEuint8(encrypted_assignment_marks)); 
     euint8 quiz_contri = TFHE.mul(percentage_for_quiz ,TFHE.asEuint8(encrypted_quiz_marks));
     euint8 midsem_contri = TFHE.mul(percentage_for_midsem ,TFHE.asEuint8(encrypted_midsem_marks));
     euint8 endsem_contri = TFHE.mul(percentage_for_endsem ,TFHE.asEuint8(encrypted_endsem_marks));

     euint8 total_marks = TFHE.add(assigment_contri , TFHE.add(quiz_contri , TFHE.add(midsem_contri , endsem_contri)));
     euint8 grade = TFHE.div(total_marks , 10);  // to employ more complex scheme in the future , for now absolute grade is calculated
        
     studentGradeWithSubjectsMap[_enrollmentNumber][_subject_id] = grade;

    }

    function calculateCGPA(uint _enrollmentNumber) public OnlyAdmin
    {
     (,,,,uint subject_code_1 , uint subject_code_2 , uint subject_code_3 , uint subject_code_4) = studentContract.getStudentData(_enrollmentNumber); 

      uint subject1_credits = subjectContract.getSubjectCredits(subject_code_1);
      uint subject2_credits = subjectContract.getSubjectCredits(subject_code_2);
      uint subject3_credits = subjectContract.getSubjectCredits(subject_code_3);
      uint subject4_credits = subjectContract.getSubjectCredits(subject_code_4);
      
      uint totalcredits = subject1_credits + subject2_credits + subject3_credits + subject4_credits;

      euint8 grade_subject1 = studentGradeWithSubjectsMap[_enrollmentNumber][subject_code_1];
      euint8 grade_subject2 = studentGradeWithSubjectsMap[_enrollmentNumber][subject_code_2];
      euint8 grade_subject3 = studentGradeWithSubjectsMap[_enrollmentNumber][subject_code_3];
      euint8 grade_subject4 = studentGradeWithSubjectsMap[_enrollmentNumber][subject_code_4];

      euint8 cgpa_unweighted = TFHE.add(
                             TFHE.add(
                                       TFHE.mul(grade_subject1 , TFHE.asEuint8(subject1_credits)) ,
                                       TFHE.mul(grade_subject2 , TFHE.asEuint8(subject2_credits)) 
                    ) ,
                             TFHE.add(
                                       TFHE.mul(grade_subject3 , TFHE.asEuint8(subject3_credits)) , 
                                       TFHE.mul(grade_subject4 , TFHE.asEuint8(subject4_credits)) 
                    )
                    );
                    
       studentContract.changeCGPA( TFHE.div(cgpa_unweighted , uint8(totalcredits)) , _enrollmentNumber);          
    }

    
    
    
}