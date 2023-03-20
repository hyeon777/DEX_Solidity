// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";


contract Dex is ERC20 {
    address public owner;
    uint256 public reserveX;
    uint256 public reserveY;
    uint256 public amountX;
    uint256 public amountY;
    uint256 public k;
    address public tokenLP;
    uint public nonce;
    uint256 public X_value;
    uint public set_LP;

    mapping (uint256 => uint[2])[] public lp_list;

    ERC20 public X;
    ERC20 public Y;

    constructor (address tokenX, address tokenY) ERC20("DREAM", "DRM") {
        owner = msg.sender;
        X = ERC20(tokenX);
        Y = ERC20(tokenY);
        nonce = 0;
        //reserveX = 0;
        //reserveY = 0;
        //amountX = 0;
        //amountY = 0;
    }
    
    function swap(uint256 tokenXAmount, uint256 tokenYAmount, uint256 tokenMinimumOutputAmount) external returns (uint256 outputAmount) {
        if(tokenXAmount != 0){
            uint256 x_value = tokenXAmount / 1000 * 999;
            amountX += x_value;
            amountY = k / amountX;
            outputAmount = reserveY - amountY;
            require(outputAmount < amountY);
        }
        else{
            uint y_value = tokenYAmount / 1000 * 999;
            amountY += y_value;
            amountX = k / amountY;
            outputAmount = reserveX - amountX;
            require(outputAmount < amountX);
        }
    }

    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount) external returns (uint LPTokenAmount){
  //수정 필요
        require(tokenXAmount > 0 && tokenYAmount > 0);
        reserveX = amountX;
        reserveY = amountY;

        if(totalSupply() == 0){
            set_LP = tokenXAmount * tokenYAmount / 10**18;
        }
        else{
            set_LP = totalSupply() * (tokenXAmount) / reserveX;
        }
        require(minimumLPTokenAmount <= set_LP);
        LPTokenAmount = set_LP;

        X.transferFrom(msg.sender, address(this), tokenXAmount);
        amountX = reserveX + tokenXAmount;

        Y.transferFrom(msg.sender, address(this), tokenYAmount);
        amountY = reserveY + tokenYAmount;

        k = amountX * amountY;



        //lp_list.push();
        //lp_list[nonce][LPTokenAmount] = [tokenXAmount, tokenYAmount];
        
        //nonce += 1; 
        //console.log("nonce: ", nonce);
        //console.log("lp", LPTokenAmount);
        //LP.transferFrom(address(this), msg.sender, LPTokenAmount);
        _mint(msg.sender, LPTokenAmount);


    }

    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount) external returns (uint tx, uint ty){
        require(minimumTokenXAmount < amountX);
        require(minimumTokenYAmount < amountY);
        tx = lp_list[nonce][LPTokenAmount][0];
        ty = lp_list[nonce][LPTokenAmount][1];
        nonce -= 1;
        require(tx>minimumTokenXAmount);
        require(ty>minimumTokenYAmount);
        X.transferFrom(address(this), msg.sender, tx);
        Y.transferFrom(address(this), msg.sender, ty);
    
       // LP.transferFrom(msg.sender, address(this), LPTokenAmount);


    }

    function transfer(address to, uint256 lpAmount) public virtual override returns (bool){
        super.transfer(to, lpAmount);
    }



}

