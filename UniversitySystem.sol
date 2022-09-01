// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AdvancedUinversitySystem {
    // Declare state variables
    address  deployer; // the owner deployer
    // task struct
    struct Tasks{
        address professor;
        address student;
        string task_description;
    }
    // array of tasks (structs)
    Tasks [] public tasks;
    // Declare two arrays for pushing students and professors
    address []  registered_professors;
    address []  registered_students;

    // mapping for Checking Repeated Professors and Students in their arrays
    // also for checking student can not register as professor and vice versa

    mapping (address => bool) is_professor_registered_before;
    mapping (address => bool) is_student_registered_before;

    mapping (address => string []) AssignedTasks;

    // constructor to set the contract deployer

    constructor (){
        deployer = msg.sender;
    }   

    //Modifiers to check if professors or students are repeated on their arrays
    
    modifier CheckProfessorRegistered{
        require (is_professor_registered_before[msg.sender] == false,"Professor already registered");
        _;
    }
    modifier CheckStudentRegistered{
        require (is_student_registered_before[msg.sender] == false,"student already registered");
        _;
    }

    // Function to Register Professors
    function Professors_Registeration () public CheckProfessorRegistered{
        require(is_student_registered_before [msg.sender] == false , "student could not be professors");
        registered_professors.push(msg.sender);
        is_professor_registered_before[msg.sender] = true;
        }
   
    
    // Function to Register Students
    function Students_Registeration () public CheckStudentRegistered {
        require(is_professor_registered_before [msg.sender] == false , "professors could not be students");
        registered_students.push(msg.sender);
        is_student_registered_before[msg.sender] = true;
    }
    
    //How many professors? 
    function Professors_Count () public view returns (uint professors_count) {
        return registered_professors.length;
    }
    //How many Students?
    function Students_Count () public view returns (uint students_count) {
        return registered_students.length;
    }

    //Function for professors to assign tasks to students
    function AssignTaskToStudent (address _student,string memory _task_description) public {
        require(is_professor_registered_before[msg.sender] == true , "you are not a professor");
        require (is_student_registered_before[_student] == true , "the provided address is not a student");
        Tasks memory Newtask = Tasks(msg.sender, _student, _task_description);
        tasks.push(Newtask);
        AssignedTasks[_student].push(_task_description);
    }

    //Function to help students for returning the tasks assigned to them.
    function GetMyTasks () public view returns (string [] memory _mytasks){
        require(is_student_registered_before[msg.sender] == true , "You are not registered as student");
        require(is_professor_registered_before[msg.sender] == false , "the provided address is a professor has no tasks");
        return AssignedTasks[msg.sender];
    }

    // Function to fire professor , the deployer (owner) only can call this function
    function FireProfessor (address _professor) public {
        require(deployer == msg.sender , "Only contract owner can call this function" );
        require(is_professor_registered_before[_professor] == true , "Professor not found, you can not remove him");
        for (uint i = 0 ; i < registered_professors.length ; i++){
            if (registered_professors[i] == _professor){
                registered_professors[i] = registered_professors[registered_professors.length -1];
            }
        }
        registered_professors.pop();
        is_professor_registered_before[_professor] = false;
    }


    //function to get all registered students ,, only deployer can call this
    function GetRegisteredStudents () public  view returns (address [] memory ){
        require(is_professor_registered_before[msg.sender] == true , "This task for professors only, You are not a professor");
        require(is_student_registered_before[msg.sender] == false , "This task for professors only, you are a student");
        return registered_students;
    }

    //function to get all registered professors ,, only deployer can call this
    function GetRegisteredProfessors () public  view returns (address [] memory ){
        require(deployer == msg.sender , "Only contract owner can call this function" );
        return registered_professors;
    }

}
