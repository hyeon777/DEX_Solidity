// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Dex is ERC20{
    address public owner;
    uint256 private reserveX=0;
    uint256 private reserveY=0;
    uint256 private accountX=0;
    uint256 private accountY=0;
    uint256 public k;
    uint256 X_value;
    uint256 set_LP;    

    constructor (address tokenX, address tokenY) ERC20("Dream", "DRM"){
        owner = msg.sender;
        ERC X = ERC20(tokenX);
        ERC Y = ERC20(tokenY);
        ERC20 LP;
    }
    
    function swap(uint256 tokenXAmount, uint256 tokenYAmount, uint256 tokenMinimumOutputAmount) external returns (uint256 outputAmount) {
        if(tokenXAmount != 0){
            uint256 x_value = tokenXAmount / 1000 * 999;
            accountX += x_value;
            accountY = k / accountX;
            outputAmount = reserveY - accountY;
            require(outputAmount < accountY);
        }
        else{
            uint y_value = tokenYAmount / 1000 * 999;
            accountY += y_value;
            accountX = k / accountY;
            outputAmount = reserveX - accountX;
            require(outputAmount < accountX);
        }
    }

    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount) external returns (uint256 LPTokenAmount){
        require(minimumLPTokenAmount < set_maximum_LP);
        set_LP = tokenXAmount + tokenYAmount;  //수정 필요
        if(tokenXAmount > 0){
            X.transferFrom(msg.sender, address(this), tokenXAmount);
            accountX = reserveX + tokenXAmount;
            reserveX = accountX;
        }
        else{
            Y.transferFrom(msg.sender, address(this), tokenYAmount);
            accountY = reserveY + tokenYAmount;
            reserveY = accountY;
        }
        k = tokenXAmount * tokenYAmount;
        if(minimumLPTokenAmount < set_LP){LPTokenAmount = minimumLPTokenAmount;}
        LP.transfer(msg.sender, LPTokenAmount);
    }

    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount) external{
        require(minimumTokenXAmount < accountX);
        require(minimumTokenYAmount < accountY);
        X.transferFrom(address(this), msg.sender, minimumTokenXAmount);
        Y.transferFrom(address(this), msg.sender, minimumTokenYAmount);
        LP.transferFrom(msg.sender, address(this), LPTokenAmount);
    }

    function transfer(address to, uint256 lpAmount) external returns (bool){
        transfer(to, lpAmount);
    }



}

