// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external returns (uint256 amountOut);
}

library TokenTransferHelper {
    // Fonction pour transférer des jetons en toute sécurité
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        require(IERC20(token).transferFrom(from, to, amount), "Transfer failed");
    }

    // Fonction pour approuver une adresse à dépenser des jetons
    function safeApprove(address token, address spender, uint256 amount) internal {
        require(IERC20(token).approve(spender, amount), "Approve failed");
    }
}

contract SimpleTokenSwap {
    // Adresse du routeur Uniswap
    address constant SWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45; 
    // Adresse WETH sur Ethereum Mainnet
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    ISwapRouter02 private immutable router;

    // Le constructeur initialise le routeur
    constructor() {
        router = ISwapRouter02(SWAP_ROUTER_02);
    }

    // Fonction de swap de jetons
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 fee
    ) external {
        // Transfert des jetons d'entrée de l'expéditeur vers ce contrat
        TokenTransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);
        // Approuver le routeur Uniswap pour dépenser les jetons d'entrée
        TokenTransferHelper.safeApprove(tokenIn, SWAP_ROUTER_02, amountIn);

        // Définir les paramètres du swap
        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        // Appeler le routeur pour exécuter le swap
        uint256 amountOut = router.exactInputSingle(params);
        
        // Vérifier que le montant de sortie est suffisant
        require(amountOut >= amountOutMin, "Insufficient output amount");
    }
}
