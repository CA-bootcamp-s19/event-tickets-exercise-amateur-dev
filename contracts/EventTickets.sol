pragma solidity ^0.5.0;


contract EventTickets {


    address public owner;

    uint  TICKET_PRICE = 100 wei;

    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyers;
        bool isOpen;
    }
    
    Event myEvent;
    

    event LogBuyTickets(address purchaser, uint ticketsNo);

    event LogGetRefund(address requester, uint refundedTicketsNo);

    event LogEndSale(address owner, uint balance);

 
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
     

    constructor(string memory description, string memory website, uint ticketsNo) public {
        owner = msg.sender;
        myEvent.description = description;
        myEvent.website = website;
        myEvent.totalTickets = ticketsNo;
        myEvent.isOpen = true;
    }
    
    
    function readEvent()public view 
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) {
            return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }


    function getBuyerTicketCount(address requester) public view returns(uint){
        return myEvent.buyers[requester];
    }
     
    

    function buyTickets(uint ticketsNo) public payable{
        emit LogBuyTickets(msg.sender, ticketsNo);
        require(myEvent.isOpen == true);
        require (msg.value >= (ticketsNo * TICKET_PRICE));
        require(myEvent.totalTickets > ticketsNo);
        myEvent.buyers[msg.sender]+=ticketsNo;
        myEvent.totalTickets-=ticketsNo;
        myEvent.sales += ticketsNo;
        uint amount = ticketsNo * TICKET_PRICE;
        uint remainingValue = msg.value - amount;
        msg.sender.transfer(remainingValue);
        emit LogBuyTickets(msg.sender, ticketsNo);
    }
    
   
    
    function getRefund() public payable{
        require(myEvent.buyers[msg.sender] > 0);
        uint returnTicketsNo = myEvent.buyers[msg.sender];
        myEvent.totalTickets+=returnTicketsNo;
        myEvent.buyers[msg.sender]=0;
        myEvent.sales -= returnTicketsNo;
        msg.sender.transfer(returnTicketsNo * TICKET_PRICE);
        emit LogGetRefund(msg.sender, returnTicketsNo);
    }
    
   
    function endSale() public payable onlyOwner{
        myEvent.isOpen = false;
        uint balance = msg.value+ (myEvent.sales * TICKET_PRICE);
        msg.sender.transfer(balance);
        emit LogEndSale(msg.sender, balance);
    }
}
