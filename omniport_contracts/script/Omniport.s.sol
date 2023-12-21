// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "forge-std/Script.sol";
import "../src/Student.sol";
import "../src/Professor.sol";
import "../src/Subject.sol";
import "../src/GradeCalc.sol";
import "../src/EndSemReview.sol";


contract Omniport is Script {
 
    function run () external {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Student studentContract = new Student(vm.envAddress("ADMIN"));
        Professor professorContract = new Professor(vm.envAddress("ADMIN"));
        Subject subjectContract = new Subject(vm.envAddress("ADMIN"));
        GradeCalc gradeCalcContract = new GradeCalc(vm.envAddress("ADMIN"), address(professorContract), address(subjectContract), address(studentContract));
        EndsemReview endsemReviewContract = new EndsemReview(vm.envAddress("ADMIN"), address(studentContract), address(professorContract));
        
        vm.stopBroadcast();
    }

}