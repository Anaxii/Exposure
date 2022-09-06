const UniswapV2Factory = artifacts.require("UniswapV2Factory");
const UniswapV2Router02 = artifacts.require("UniswapV2Router02");
const WAVAX = artifacts.require("WAVAX");
const USDC = artifacts.require("USDC");
const TokenA = artifacts.require("TokenA");
const TokenB = artifacts.require("TokenB");
const TokenC = artifacts.require("TokenC");
const TokenD = artifacts.require("TokenD");
const TokenE = artifacts.require("TokenE");
const ExposureETF = artifacts.require("ExposureBasket");
const ERC20Factory = artifacts.require("ERC20Factory")
const ExposureFactory = artifacts.require("ExposureFactory")
const ExposureManager = artifacts.require("ExposureManager")
const feeToSetter = "0xAb41077bA83A35013534104Ac7ba7cA76e86828f";


module.exports = async (deployer, network) => {
    let _wavax = "0x72187342BC71CAd08FcCC361ff8336A684dd6883"
    let _usdc = "0x803871f6BB32a9C1230cdc182002f8e058791A9A"
    let _oracle = ["0x26cCFEC50D064DCfb8e0ffDC6A68613B9377531C"]
    let _router = ["0x2D99ABD9008Dc933ff5c0CD271B88309593aB921"]
    let _owner = "0x56A52b69179fB4BF0d0Bc9aefC340E63c36d3895"
    let _XPSRAddress = _owner
    await deployer.deploy(ExposureManager, _wavax, _usdc, _usdc, _oracle, _router)
    let manager = await ExposureManager.deployed()



    await deployer.deploy(ExposureETF, "test", "test", _usdc, _owner, _XPSRAddress, manager.address)
    let basket = await ExposureETF.deployed()
    manager.transferOwnership(basket.address)
    console.log(basket.address, manager.address)

    // let start = await basket.startETF()
    // console.log("start")
    // for (const i in tokens) {
    //     let m = await manager.batchNewAssetManager(tokens[i].tokenAddress, [tokens[i].pairAddress], [tokens[i].quoteAddress], _oracle, _router)
    //     console.log(m)
    //     break
    // }
    //
    // let init = await basket.initETF()
    // console.log("DONE")




    // await deployer.deploy(ERC20Factory)
    // let eFactory = await ERC20Factory.deployed()
    // await deployer.deploy(WAVAX)
    // await deployer.deploy(USDC)
    // let wavax = await WAVAX.deployed()
    // let usdc = await USDC.deployed()
    // //
    // await deployer.deploy(UniswapV2Factory, feeToSetter)
    // let factory = await UniswapV2Factory.deployed()
    // // // //
    // await deployer.deploy(UniswapV2Router02, factory.address, WAVAX.address);
    // let router = await UniswapV2Router02.deployed()
    // console.log(eFactory.address, factory.address, router.address, wavax.address, usdc.address)
    // await deployer.deploy(ExposureFactory);

};
