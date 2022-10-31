pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding
{
    mapping(address=>uint) public contributor;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOFContributor;

    struct request
    {
        string description;
        address payable recipient;
        uint value;
        uint noOfVoters;
        bool completed;
        mapping(address=>bool) voters;
    }
    mapping(uint=>request) public requests;
    uint public numRequests;
   
   constructor(uint _target,uint _deadline)
   {
       target=_target;
       deadline=block.timestamp+_deadline; //10 sec + 3600sec(1hr)
       minimumContribution=100 wei;
       manager=msg.sender;
   }

   function sendEth() public payable
   {
        require(block.timestamp <=deadline,"Deadline has passed");
        require(msg.value >=minimumContribution,"Minimum contribution has not met");
        
        if(contributor[msg.sender]==0)
        {
            noOFContributor++;
        }
        contributor[msg.sender]+=msg.value;
        raisedAmount+=msg.value;

   }
   function getContractBalance() public view returns(uint)
   {
       return address(this).balance;
   }

   function refund() public
   {
       require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
       require(contributor[msg.sender]>0 ,"You have never paid");
       address payable user = payable(msg.sender);
       user.transfer( contributor[msg.sender]);
       contributor[msg.sender]=0;
   }

   modifier onlyManager()
   {
      require(msg.sender==manager,"Only manager can access this function");
      _;
   }
   function createRequest(string memory _description,address payable _recipient,uint _value) public onlyManager
   {
      request storage newrequest = requests[numRequests];
      numRequests++;
      newrequest.description=_description;
      newrequest.recipient=_recipient;
      newrequest.value=_value;
      newrequest.completed=false;
      newrequest.noOfVoters=0;

   }

   function voteRequest(uint _requestNum) public
   {
      require(contributor[msg.sender]>0,"You must be a contributor");
      request storage thisRequest=requests[_requestNum];
      require(thisRequest.voters[msg.sender]==false,"You have already voted");
      thisRequest.voters[msg.sender]=true;
      thisRequest.noOfVoters++;
      
   }

   function makepayment(uint _requestNum) public onlyManager 
   {
      require(raisedAmount>=target ,"More funds required");
      request storage thisrequest=requests[_requestNum];
      require(thisrequest.completed==false,"request has been already been completed");
      require(thisrequest.noOfVoters>noOFContributor/2,"Majority does not support");
      thisrequest.recipient.transfer(thisrequest.value);
      thisrequest.completed=true;


   }

    
}