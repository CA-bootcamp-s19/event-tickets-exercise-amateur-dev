pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {

    
    address public owner;
    uint   PRICE_TICKET = 100 wei;

   
    uint public idGenerator;
    
  
    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyers;
        bool isOpen;
    }

    
    mapping(uint => Event) events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

  
    function addEvent( string memory _description, string memory _website, uint _totalTickets) public onlyOwner returns(uint){
        events[idGenerator] = Event({description:_description, website:_website, totalTickets:_totalTickets, sales:0, isOpen:true});
        idGenerator++;
        emit LogEventAdded(_description, _website, _totalTickets, idGenerator);
        return idGenerator;

    }


    function readEvent(uint eventId)public view 
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) {
        Event memory myEvent = events[eventId];
        return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }     

    
    function buyTickets(uint eventId, uint ticketsNo) public payable{
        require(events[eventId].isOpen == true);
        require (msg.value >= (ticketsNo * PRICE_TICKET));
        require(events[eventId].totalTickets > ticketsNo);
        events[eventId].buyers[msg.sender]+=ticketsNo;
        events[eventId].totalTickets-=ticketsNo;
        events[eventId].sales += ticketsNo;
        uint amount = ticketsNo * PRICE_TICKET;
        uint remainingValue = msg.value - amount;
        msg.sender.transfer(remainingValue);
        emit LogBuyTickets(msg.sender, eventId, ticketsNo);
    }

    
    function getRefund(uint eventId) public payable{
        require(events[eventId].buyers[msg.sender] > 0);
        uint returnTicketsNo = events[eventId].buyers[msg.sender];
        events[eventId].totalTickets+=returnTicketsNo;
        events[eventId].buyers[msg.sender]=0;
        events[eventId].sales -= returnTicketsNo;
        msg.sender.transfer(returnTicketsNo * PRICE_TICKET);
        emit LogGetRefund(msg.sender, eventId, returnTicketsNo);
    }

    
    function getBuyerNumberTickets(uint eventId) public view returns(uint){
        return events[eventId].buyers[msg.sender];
    }

    
    function endSale(uint eventId) public payable onlyOwner{
        events[eventId].isOpen = false;
        uint balance = msg.value+ (events[eventId].sales * PRICE_TICKET);
        msg.sender.transfer(balance);
        emit LogEndSale(msg.sender, balance, eventId);
    }
}
