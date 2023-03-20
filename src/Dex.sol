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
    uint256 public set_LP;

    ERC20 public X;
    ERC20 public Y;

    constructor (address tokenX, address tokenY) ERC20("DREAM", "DRM") {
        owner = msg.sender;
        X = ERC20(tokenX);
        Y = ERC20(tokenY);
    }
    
    function swap(uint256 tokenXAmount, uint256 tokenYAmount, uint256 tokenMinimumOutputAmount) external returns (uint256 outputAmount) {
        require((tokenXAmount==0)|| (tokenYAmount == 0));
        require(amountX >0 && amountY > 0);
        (reserveX, reserveY) = amount_update();
        k = amountX * amountY;

        if(tokenXAmount > 0){
            uint256 x_value = tokenXAmount / 1000 * 999;
            amountY = k / (amountX + x_value);
            outputAmount = reserveY - amountY;

            require(outputAmount < amountY, "outputAmount is bigger than amount of Y");
            require(tokenMinimumOutputAmount < outputAmount, "you claim too much token");
            X.transferFrom(msg.sender, address(this), tokenXAmount);
            Y.transfer(msg.sender, outputAmount);

            amount_update();


        }
        else{
            uint256 y_value = tokenYAmount / 1000 * 999;
            amountX = k / (amountY + y_value);
            outputAmount = reserveX - amountX;

            require(outputAmount < amountX, "outputAmount is bigger than amount of X");
            require(tokenMinimumOutputAmount < outputAmount, "you claim too much token");
            Y.transferFrom(msg.sender, address(this), tokenYAmount);
            X.transfer(msg.sender, outputAmount);

            amount_update();
        }
    }

    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount) external returns (uint LPTokenAmount){
        require(tokenXAmount > 0 && tokenYAmount > 0);
        (reserveX, ) = amount_update();
        (, reserveY) = amount_update();

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

        _mint(msg.sender, LPTokenAmount);


    }

    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount) external returns (uint tx, uint ty){
        amount_update();
        require(balanceOf(msg.sender) >= LPTokenAmount, "more remove than owning");

        tx = amountX * LPTokenAmount / totalSupply();
        ty = amountY * LPTokenAmount / totalSupply();

        require(tx>=minimumTokenXAmount);
        require(ty>=minimumTokenYAmount);

        X.transfer(msg.sender, tx);
        Y.transfer(msg.sender, ty);
        _burn(msg.sender, LPTokenAmount);

        amount_update();


    }

    function transfer(address to, uint256 lpAmount) public virtual override returns (bool){
        super.transfer(to, lpAmount);
    }

    function amount_update() internal returns (uint256, uint256) {
        amountX = X.balanceOf(address(this));
        amountY = Y.balanceOf(address(this));

        return (amountX, amountY);
    }



}

