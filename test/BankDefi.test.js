const { expect } = require("chai");
const { ethers } = require("hardhat");

let BankDefi, bankdefi, XToken, ERC20Dummy, ERC721Dummy, ERC1155Dummy, FPP, fpp2, fpp3, BankDefiv2, bankdefiv2

describe("BankDeFi", () => {
    beforeEach(async () => {
        const [owner, acct1, acct2] = await ethers.getSigners();
        BankDefi = await ethers.getContractFactory("MyContract");
        bankdefi = await await upgrades.deployProxy(BankDefi, { kind: "uups" });
        await bankdefi.deployed();
        ERC20Dummy = await ethers.getContractFactory("DummyERC20");
        XToken = await ERC20Dummy.deploy();
        await XToken.deployed();
        ERC721Dummy = await ethers.getContractFactory("DummyERC721");
        FPP = await ERC721Dummy.deploy();
        await FPP.deployed();
        ERC721Dummy = await ethers.getContractFactory("DummyERC721");
        fpp2 = await ERC721Dummy.deploy();
        await fpp2.deployed();
        ERC1155Dummy = await ethers.getContractFactory("DummyERC1155");
        fpp3 = await ERC1155Dummy.deploy();
        await fpp3.deployed();
    });

    it("should be able to deposit ERC20", async () => {
        const [owner, acct1, acct2] = await ethers.getSigners();
        await XToken.mint(acct1.address, 10);
        expect(await XToken.balanceOf(acct1.address)).to.equal(10);
        await XToken.connect(acct1).approve(bankdefi.address, 10);
        expect(await XToken.allowance(acct1.address, bankdefi.address)).to.equal(10);
        await bankdefi.connect(acct1).depositERC20(XToken.address, 10, { value: ethers.utils.parseEther("0.001") });
        expect (await bankdefi.connect(acct1).getTokenBalance(XToken.address)).to.equal(10);
    });

    it("should be able to withdraw ERC20", async () => {
        const [owner, acct1, acct2] = await ethers.getSigners();
        await XToken.mint(acct1.address, 10);
        await XToken.connect(acct1).approve(bankdefi.address, 10);
        await bankdefi.connect(acct1).depositERC20(XToken.address, 10, { value: ethers.utils.parseEther("0.001") });

        await expect(bankdefi.connect(acct1).withdrawERC20(XToken.address, 10)).to.be.reverted;
        await bankdefi.addAdmin(acct2.address);
        await bankdefi.connect(acct2).unlockUserERC20(acct1.address, true);
        await bankdefi.connect(acct1).withdrawERC20(XToken.address, 10);
        expect (await XToken.balanceOf(acct1.address)).to.equal(10);
    });

    it("should be able deposit ERC721", async () => {
        const [owner, acct1, acct2] = await ethers.getSigners();
        await FPP.mint(acct1.address, 1);
        await FPP.connect(acct1).approve(bankdefi.address, 1);
        expect (await FPP.ownerOf(1)).to.equal(acct1.address);
        await bankdefi.connect(acct1).depositERC721(FPP.address, 1, { value: ethers.utils.parseEther("0.001") });
        expect (await bankdefi.connect(acct1).getNftBalance(FPP.address)).to.equal(1);

        await fpp2.mint(acct1.address, 1);
        await fpp2.connect(acct1).approve(bankdefi.address, 1);
        expect (await fpp2.ownerOf(1)).to.equal(acct1.address);
        await bankdefi.connect(acct1).depositERC721(fpp2.address, 1, { value: ethers.utils.parseEther("0.001") });
        expect (await bankdefi.connect(acct1).getNftBalance(fpp2.address)).to.equal(1);
    });

    it("should be able to withdraw ERC721", async () => {
        const [owner, acct1, acct2] = await ethers.getSigners();
        await FPP.mint(acct2.address, 1);
        await FPP.connect(acct2).approve(bankdefi.address, 1);
        await bankdefi.connect(acct2).depositERC721(FPP.address, 1, { value: ethers.utils.parseEther("0.001") });
        await expect (bankdefi.connect(acct2).withdrawERC721(FPP.address, 1)).to.be.reverted;
        await bankdefi.addAdmin(acct1.address);
        await bankdefi.connect(acct1).unlockUserERC721(acct2.address, true);
        await bankdefi.connect(acct2).withdrawERC721(FPP.address, 1);
    });

    it("should be able to upgrade Contract", async () => {
        const [owner, acct1, acct2] = await ethers.getSigners();
        BankDefiv2 = await ethers.getContractFactory("MyContractv2");
        bankdefiv2 = await upgrades.upgradeProxy(bankdefi.address, BankDefiv2);
        await bankdefiv2.deployed();
        await XToken.mint(acct1.address, 10);
        await XToken.connect(acct1).approve(bankdefiv2.address, 10);
        await bankdefiv2.connect(acct1).depositERC20(XToken.address, 10, { value: ethers.utils.parseEther("0.001") });

        await fpp3.mint(acct1.address, 1, 10);
    });
});