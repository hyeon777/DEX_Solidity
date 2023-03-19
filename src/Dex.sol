// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract Dex {
    address public owner;
    uint256 public reserveX;
    uint256 public reserveY;
    uint256 public accountX;
    uint256 public accountY;
    uint256 public k;
    uint public nonce;
    uint256 public X_value;
    uint256 public set_LP;

    mapping (uint256 => uint[2])[] public lp_list;

    ERC20 public X;
    ERC20 public Y;
    ERC20 LP;

    constructor (address tokenX, address tokenY) {
        owner = msg.sender;
        X = ERC20(tokenX);
        Y = ERC20(tokenY);
        LP = new ERC20("DREAM", "DRM");
        nonce = 0;
        reserveX = 0;
        reserveY = 0;
        accountX = 0;
        accountY = 0;
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

    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount) external returns (uint LPTokenAmount){
        set_LP = (tokenXAmount + tokenYAmount)/2;  //수정 필요

        X.transferFrom(msg.sender, address(this), tokenXAmount);
        reserveX = accountX;
        accountX = reserveX + tokenXAmount;


        Y.transferFrom(msg.sender, address(this), tokenYAmount);
        reserveY = accountY;
        accountY = reserveY + tokenYAmount;

        k = accountX * accountY;

        if(minimumLPTokenAmount < set_LP){LPTokenAmount = set_LP;}
        //lp_list.push();
        //lp_list[nonce][LPTokenAmount] = [tokenXAmount, tokenYAmount];
        
        //nonce += 1; 
        //console.log("nonce: ", nonce);
        //console.log("lp", LPTokenAmount);
        LP.transferFrom(address(this), msg.sender, LPTokenAmount);

    }

    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount) external returns (uint tx, uint ty){
        require(minimumTokenXAmount < accountX);
        require(minimumTokenYAmount < accountY);
        tx = lp_list[nonce][LPTokenAmount][0];
        ty = lp_list[nonce][LPTokenAmount][1];
        nonce -= 1;
        require(tx>minimumTokenXAmount);
        require(ty>minimumTokenYAmount);
        X.transferFrom(address(this), msg.sender, tx);
        Y.transferFrom(address(this), msg.sender, ty);
    
        LP.transferFrom(msg.sender, address(this), LPTokenAmount);


    }

    function transfer(address to, uint256 lpAmount) public virtual returns (bool){
        transfer(to, lpAmount);
    }



}

