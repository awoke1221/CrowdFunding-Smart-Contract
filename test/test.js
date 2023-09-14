// Testing the crowdfunding Smart Contract

const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("CrowdFunding", ()=> {
  // Deploy the contract and retrive the test accounts
  let crowdfunding
  let owner
  let contributor1
  

  const goalAmount = ethers.utils.parseEther("10")
  const deadline = 86400 // 1 day
  
  
  beforeEach( async ()=>{
    // Deploy The Contract 
    [owner, contributor1] = await ethers.getSigners()
    const CrowdFunding = await ethers.getContractFactory("Crowdfunding")
    crowdfunding = await CrowdFunding.deploy()

    await crowdfunding.createCampaign(goalAmount, deadline)
  })

  it ("Create a Campaign", async()=> {
    const campaign = await crowdfunding.campaigns(0)

    expect(campaign.goalAmount).to.equal(goalAmount)
    expect(campaign.currentAmount).to.equal(0)
    expect(campaign.isClosed).to.equal(false)
    expect(campaign.owner).to.equal(owner.address)
  })

  it("Should contribute to a campaign", async function () {
    const contributionAmount = ethers.utils.parseEther("5");
    await crowdfunding.connect(contributor1).contribute(0, { value: contributionAmount });

    const campaign = await crowdfunding.campaigns(0);
    expect(campaign.goalAmount).to.equal(goalAmount);
    expect(campaign.currentAmount).to.equal(contributionAmount);
    expect(campaign.isFunded).to.equal(false);
  });

  it("Close the campaign", async ()=>{
    
    await crowdfunding.connect(owner).closeCampaign(0)
    const campaign = await crowdfunding.campaigns(0)

    expect(campaign.isClosed).to.equal(true)
  
  })

})