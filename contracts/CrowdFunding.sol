// SPDX-License-Identifier: MIT 
pragma solidity >=0.8.0 <0.9.0;

contract Crowdfunding {
    struct Campaign {
        address payable owner;
        uint goalAmount;
        uint deadline;
        uint currentAmount;
        bool isFunded;
        bool isClosed;
    }

    Campaign[] public campaigns;
    event CampaignCreated(uint campaignIndex, address owner, uint goalAmount, uint deadline);
    event ContributionMade(uint campaignIndex, address contributor, uint amount);

    modifier campaignActive(uint _campaignIndex) {
        require(!campaigns[_campaignIndex].isClosed, "Campaign is closed");
        require(block.timestamp <= campaigns[_campaignIndex].deadline, "The deadline for this campaign has passed");
        _;
    }

    modifier onlyCreator(uint _campaignIndex) {
        require(msg.sender == campaigns[_campaignIndex].owner, "Only the campaign owner can perform this action");
        _;
    }

    function createCampaign(uint _goalAmount, uint _duration) public {
        Campaign memory newCampaign = Campaign({
            owner: payable(msg.sender),
            goalAmount: _goalAmount,
            currentAmount: 0,
            deadline: block.timestamp + _duration,
            isFunded: false,
            isClosed: false
        });

        campaigns.push(newCampaign);
        emit CampaignCreated(campaigns.length - 1, msg.sender, _goalAmount, newCampaign.deadline);
    }

    function contribute(uint _campaignIndex) public payable campaignActive(_campaignIndex) {
        Campaign storage campaign = campaigns[_campaignIndex];
        require(msg.value > 0, "Contribution amount must be greater than zero");
        campaign.currentAmount += msg.value;
        emit ContributionMade(_campaignIndex, msg.sender, msg.value);
    }

    function closeCampaign(uint _campaignIndex) public onlyCreator(_campaignIndex) campaignActive(_campaignIndex) {
        Campaign storage campaign = campaigns[_campaignIndex];
        campaign.isClosed = true;
        if (campaign.isFunded) {
            campaign.owner.transfer(campaign.currentAmount);
        }
    }

    function campaignDetails(uint _campaignIndex) public view returns(address, uint, uint, uint, bool, bool) {
        Campaign memory campaign = campaigns[_campaignIndex];
        return (
            campaign.owner,
            campaign.goalAmount,
            campaign.deadline,
            campaign.currentAmount,
            campaign.isClosed,
            campaign.isFunded
        );
    }
}