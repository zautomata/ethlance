pragma solidity ^0.4.4;

import "ethlanceSetter.sol";
import "contractLibrary.sol";

contract EthlanceContract is EthlanceSetter {

    event onJobProposalAdded(uint contractId, uint indexed employerId);
    event onJobContractAdded(uint contractId, uint indexed freelancerId);
    event onJobContractFeedbackAdded(uint contractId, uint indexed userId);
    event onJobInvitationAdded(uint jobId, uint indexed freelancerId);

    function EthlanceContract(address _ethlanceDB) {
        if(_ethlanceDB == 0x0) throw;
        ethlanceDB = _ethlanceDB;
    }

    function addJobContract(
        uint contractId,
        string description,
        bool isHiringDone
    )
        onlyActiveSmartContract
        onlyActiveEmployer
    {
        if (bytes(description).length > getConfig("max-contract-desc")) throw;
        ContractLibrary.addContract(ethlanceDB, getSenderUserId(), contractId, description, isHiringDone);
        var freelancerId = ContractLibrary.getFreelancer(ethlanceDB, contractId);
        onJobContractAdded(contractId, freelancerId);
    }

    function addJobContractFeedback(
        uint contractId,
        string feedback,
        uint8 rating
    )
        onlyActiveSmartContract
        onlyActiveUser
    {
        if (bytes(feedback).length > getConfig("max-feedback")) throw;
        if (bytes(feedback).length < getConfig("min-feedback")) throw;
        if (rating > 100) throw;
        var senderId = getSenderUserId();
        ContractLibrary.addFeedback(ethlanceDB, contractId, senderId, feedback, rating);
        var freelancerId = ContractLibrary.getFreelancer(ethlanceDB, contractId);
        var employerId = ContractLibrary.getEmployer(ethlanceDB, contractId);
        uint receiverId;
        if (senderId == freelancerId) {
            receiverId = employerId;
        } else {
            receiverId = freelancerId;
        }
        onJobContractFeedbackAdded(contractId, receiverId);
    }

    function addJobProposal(
        uint jobId,
        string description,
        uint rate
    )
        onlyActiveSmartContract
        onlyActiveFreelancer
    {
        if (bytes(description).length > getConfig("max-proposal-desc")) throw;
        var contractId = ContractLibrary.addProposal(ethlanceDB, jobId, getSenderUserId(), description, rate);
        var employerId = JobLibrary.getEmployer(ethlanceDB, jobId);
        onJobProposalAdded(contractId, employerId);
    }

    function addJobInvitation(
        uint jobId,
        uint freelancerId,
        string description
    )
        onlyActiveSmartContract
        onlyActiveEmployer
    {
        if (bytes(description).length > getConfig("max-invitation-desc")) throw;
        ContractLibrary.addInvitation(ethlanceDB, getSenderUserId(), jobId, freelancerId, description);
        onJobInvitationAdded(jobId, freelancerId);
    }
}