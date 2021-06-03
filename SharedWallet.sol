//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

//these imports work only on Remix, to use this contract locally please visit OpenZeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";


contract Allowance is Ownable {
    
    using SafeMath for uint;
    event AllowanceChanged(address indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount);
    
    mapping(address => uint) public allowance;
    
    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }
    
    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not allowed");
        _;
    }
    
    function addAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] + _amount);
        allowance[_who] = _amount;
    }
    
    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount));
        allowance[_who] = allowance[_who].sub(_amount);
    }
}

contract SharedWallet is Allowance {
    
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);
    
    using SafeMath for uint;

    mapping(address => uint) public contractBalance;
    
    function receiveMoney() public payable {
        assert(contractBalance[msg.sender] + uint(msg.value) >= contractBalance[msg.sender]);
        emit MoneyReceived(msg.sender, msg.value);
        contractBalance[msg.sender] = contractBalance[msg.sender].add(msg.value);
    }
    
    function withdrawMoneyFromContract(address payable _to, uint _amount) public payable onlyOwner {
        assert(contractBalance[msg.sender].sub(_amount) <= contractBalance[msg.sender]);
        contractBalance[msg.sender] = contractBalance[msg.sender].sub(msg.value);
        _to.transfer(_amount);
    }
    
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "There are not enough funds in the contract");
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    receive() external payable {
        receiveMoney();
    }
}