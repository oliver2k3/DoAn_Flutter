package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.DepositRequestDao;
import com.nhom7.qltd.dao.StatusDao;
import com.nhom7.qltd.dao.TransitionDao;
import com.nhom7.qltd.dao.UserDao;
import com.nhom7.qltd.dto.RequestDepositDto;
import com.nhom7.qltd.model.DepositRequestEntity;
import com.nhom7.qltd.model.StatusEntity;
import com.nhom7.qltd.model.TransitionEntity;
import com.nhom7.qltd.model.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DepositRequestService {
    private final DepositRequestDao depositRequestDAO;
    private final UsersService userService;
    private final TransitionDao transitionDAO;
    private final StatusDao statusDao;
    private final UserDao userDao;
    public void createDepositRequest(RequestDepositDto requestDepositDto) {
        UserEntity requester = userService.getUserByEmail(requestDepositDto.getRequesterEmail());
        UserEntity receiver = userDao.findByCardNumberAndBank(requestDepositDto.getReceiver(),requestDepositDto.getReceiveBank()).orElseThrow(
                () -> new IllegalArgumentException("Receiver not found")
        );

        DepositRequestEntity depositRequest = new DepositRequestEntity();
        depositRequest.setRequester(requester);
        depositRequest.setReceiver(receiver);
        depositRequest.setAmount(requestDepositDto.getAmount());
        StatusEntity status = statusDao.getStatusById(1);
        depositRequest.setStatus(status); // Pending
        depositRequest.setCreatedDate(LocalDateTime.now());
        depositRequest.setMessage(requestDepositDto.getMessage());
        depositRequestDAO.save(depositRequest);

    }

    public void approveDepositRequest(int requestId) {
        DepositRequestEntity depositRequest = depositRequestDAO.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Deposit request not found"));
        if (depositRequest.getStatus().getId() != 1) {
            throw new IllegalArgumentException("Deposit request is not in a pending state");
        }

        UserEntity requester = depositRequest.getRequester();
        UserEntity receiver = depositRequest.getReceiver();

        receiver.setBalance(receiver.getBalance() - depositRequest.getAmount());
        requester.setBalance(requester.getBalance() + depositRequest.getAmount());

        userService.updateUser(receiver);
        userService.updateUser(requester);
        StatusEntity status = statusDao.getStatusById(2);
        depositRequest.setStatus(status); // Approved
        depositRequest.setApprovedDate(LocalDateTime.now());

        depositRequestDAO.save(depositRequest);
        TransitionEntity transitionEntity = new TransitionEntity();
        transitionEntity.setFromUser(receiver.getCardNumber());
        transitionEntity.setToUser(requester.getCardNumber());
        transitionEntity.setAmount(depositRequest.getAmount());
        transitionEntity.setSenderBank(receiver.getBank());
        transitionEntity.setReceiverBank(requester.getBank());
        transitionEntity.setSenderName(receiver.getName());
        transitionEntity.setReceiverName(requester.getName());
        transitionEntity.setFee(0.0);
        transitionEntity.setMessage("Chap nhan yeu cau gui tien");
        transitionEntity.setCreated(LocalDateTime.now());
        transitionDAO.save(transitionEntity);
//        StatusEntity status = statusDao.getStatusById(2);
//        depositRequest.setStatus(status); // Approved
//        depositRequest.setApprovedDate(LocalDateTime.now());
//        depositRequestDAO.save(depositRequest);
//
//        TransitionEntity transition = new TransitionEntity();
//        transition.setFromUser(receiver.getCardNumber());
//        transition.setToUser(requester.getCardNumber());
//        transition.setAmount(depositRequest.getAmount());
//        transition.setCreated(LocalDateTime.now());
//        transitionDAO.save(transition);
    }
    public List<DepositRequestEntity> getSentRequests(String email) {
        UserEntity user = userService.getUserByEmail(email);
        return depositRequestDAO.findByRequester(user);
    }

    public List<DepositRequestEntity> getReceivedRequests(String email) {
        UserEntity user = userService.getUserByEmail(email);
        return depositRequestDAO.findByReceiver(user);
    }
    public List<DepositRequestEntity> getAllRequests(String email) {
        UserEntity user = userService.getUserByEmail(email);
        List<DepositRequestEntity> sentRequests = depositRequestDAO.findByRequester(user);
        List<DepositRequestEntity> receivedRequests = depositRequestDAO.findByReceiver(user);
        sentRequests.addAll(receivedRequests);
        return sentRequests;
    }
    public void rejectDepositRequest(int requestId) {
        DepositRequestEntity depositRequest = depositRequestDAO.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Deposit request not found"));

        if (depositRequest.getStatus().getId() != 1) { // Ensure the request is in a pending state
            throw new IllegalArgumentException("Deposit request is not in a pending state");
        }
        StatusEntity status = statusDao.getStatusById(3);
        depositRequest.setStatus(status); // Assuming 3 represents 'Rejected'
        depositRequestDAO.save(depositRequest);
    }

}