create table account(accountNumber int primary key auto_increment, 
customerName varchar(30) not null, balance numeric(10,2));

insert into account(customerName,balance) values("Nandi",10000);
insert into account(customerName,balance) values("Nandu",20000);
insert into account(customerName,balance) values("Shree",5000);



create table account_update(accountNumber int,
customerName varchar(30) not null,
changed_id timestamp,
old_balance numeric(10,2) not null,
transaction_amount numeric(10,2) not null,
transactionType varchar(30) not null,
new_balance numeric(10,2) not null);



delimiter //
create trigger account_update_credit  before update on account for each row
begin
if(old.balance<new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance, transaction_amount)
    values(old.accountNumber,old.customerName, now(),'credit', old.balance, new.balance, new.balance-old.balance);
    END IF;
end//


delimiter !!
create trigger account_update_debit  before update on account for each row
begin
if(old.balance>new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance, transaction_amount)
    values(old.accountNumber,old.customerName, now(),'debit', old.balance, new.balance, new.balance-old.balance);
    END IF;
end!!

drop trigger before_withdrawal;

update account set balance=balance+50000 where accountNumber=2;

-- CREATE PROCEDURE HOURLY_SUM -- 
DELIMITER //
CREATE PROCEDURE HOURLY_SUM (IN Account_No INT, OUT WTotal numeric(10,2), OUT DTotal numeric(10,2))
BEGIN
    SELECT sum(transaction_amount) INTO WTotal FROM advjava.account_update
	WHERE transactiontype = 'debit' AND accountnumber=Account_No AND changed_id >= Date_sub(now(),interval 1 hour);
    
    SELECT sum(transaction_amount) INTO DTotal FROM advjava.account_update
	WHERE transactiontype = 'credit' AND accountnumber=Account_No AND changed_id >= Date_sub(now(),interval 1 hour);
END //

-- CALLING THE PROCEDURE --
CALL HOURLY_SUM(1, @WTotal, @DTotal);

-- DROP THE PROCEDURE --
DROP PROCEDURE HOURLY_SUM;

-- DISPLAYING THE CALLED PROCEDURE --
SELECT @WTotal, @DTotal;

-- CREAETING EVENT TO CALL PROCEDURE HOURLY--
CREATE EVENT MyEvent
    ON SCHEDULE EVERY 1 HOUR
    DO
      CALL HOURLY_SUM(1, @WTotal, @DTotal);

-- DROP THR EVENT --
DROP EVENT MyEvent;