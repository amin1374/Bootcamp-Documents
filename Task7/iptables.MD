## What is Iptables?
Iptables is a user-space utility program that allows administrators to configure and manage the packet filtering ruleset in the Linux kernel's networking stack. It acts as a firewall by examining network traffic and making decisions based on predefined rules. These rules determine whether to allow, deny, or modify the packets passing through the system.

Understanding the Basics:
Iptables operates on the concept of tables and chains. Tables are collections of chains, while chains contain a series of rules. Each rule consists of a set of criteria that packets must meet to match the rule, along with an action to be taken if a match occurs.

## How iptables Work
Network traffic is made up of packets. Data is broken up into smaller pieces (called packets), sent over a network, then put back together. Iptables identifies the packets received and then uses a set of rules to decide what to do with them.

Iptables filters packets based on:

`Tables`: Tables are files that join similar actions. A table consists of several chains.

`Chains`: A chain is a string of rules. When a packet is received, iptables finds the appropriate table, then runs it through the chain of rules until it finds a match.

`Rules`: A rule is a statement that tells the system what to do with a packet. Rules can block one type of packet, or forward another type of packet. The outcome, where a packet is sent, is called a target.

`Targets`: A target is a decision of what to do with a packet. Typically, this is to accept it, drop it, or reject it (which sends an error back to the sender).


![Alt text](https://github.com/amin1374/Bootcamp-Documents/blob/master/Task7/pictures/iptables.jpg)

## Tables and Chains
Linux firewall iptables has four default tables. We will list all four along with the chains each table contains.

### 1. Filter

The Filter table is the most frequently used one. It acts as a bouncer, deciding who gets in and out of your network. It has the following default chains:

`INPUT`: This table controls traffic that is coming into the system.

`OUTPUT`: This table controls traffic that is going out of the system.

`FORWARD`: This table controls traffic that is being routed through the system.

### 2. Network Address Translation (NAT)

This table contains NAT (Network Address Translation) rules for routing packets to networks that cannot be accessed directly. When the destination or source of the packet has to be altered, the NAT table is used. It includes the following chains:

`Prerouting` – this chain assigns packets as soon as the server receives them.

`Output` – works the same as the output chain we described in the filter table.

`Postrouting` – the rules in this chain allow making changes to packets after they leave the output chain.

### 3. Mangle

The Mangle table adjusts the IP header properties of packets. The table has all the following chains we described above:

Prerouting

Postrouting

Output

Input

Forward

### 4. Raw

The Raw table is used to exempt packets from connection tracking. The raw table has two of the chains we previously mentioned:

Prerouting

Output

### 5. Security (Optional)

Some versions of Linux also use a Security table to manage special access rules. This table includes `input`, `output`, and `forward` chains, much like the filter table.

## Targets
A target is what happens after a packet matches a rule criteria. Non-terminating targets keep matching the packets against rules in a chain even when the packet matches a rule.

With terminating targets, a packet is evaluated immediately and is not matched against another chain. The terminating targets in Linux iptables are:

`Accept` – this rule accepts the packets to come through the iptables firewall.

`Drop` – the dropped package is not matched against any further chain. When Linux iptables drop an incoming connection to your server, the person trying to connect does not receive an error. It appears as if they are trying to connect to a non-existing machine.

`Return` – this rule sends the packet back to the originating chain so you can match it against other rules.

`Reject` – the iptables firewall rejects a packet and sends an error to the connecting device.



## Rules

An iptables rule consists of three parts:

`Match`: This part specifies the criteria that must be met for the rule to be applied. The match can be a variety of things, such as the source or destination IP address, port number, or protocol.

`Action`: This part specifies what to do with the packet if it matches the criteria. The action can be ACCEPT, DROP, REJECT, or RETURN.

`Target`: This part specifies the next chain to be evaluated if the packet does not match the criteria. The target can be another chain or a special value such as ACCEPT or DROP.

Here is an example of an iptables rule:
```
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
```
This rule allows incoming traffic from the 192.168.1.0/24 subnet to port 22. The -`s` option specifies the source IP address, the `-p` option specifies the protocol, and the `--dport` option specifies the destination port. The `-j `option specifies the action to be taken, which in this case is `ACCEPT`.

## How to use iptables

To use iptables, you need to be root or have sudo privileges. You can then use the iptables command to create, modify, and delete rules.

Here are some basic iptables commands:
```
iptables -L: This command lists all of the rules in the tables.

iptables -A: This command adds a rule to the end of a chain.

iptables -D: This command deletes a rule from a chain.

iptables -I: This command inserts a rule into a chain at a specific position.

iptables -R: This command replaces a rule in a chain.

iptables -F: This command flushes all of the rules in a table.

iptables -S: This command saves the iptables rules to a file.

iptables-restore: This command restores the iptables rules from a file.
```

some examples of how to use iptables commands:

To list all of the rules in the filter table, you would use the following command:
```
iptables -L filter
```
To add a rule to the end of the INPUT chain in the filter table, you would use the following command:
```
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
```
To delete a rule from the INPUT chain in the filter table, you would use the following command:
```
iptables -D INPUT -s 192.168.1.0/24 -p tcp --dport 22
```
To insert a rule at a specific position in the INPUT chain in the filter table, you would use the following command:
```
iptables -I INPUT 1 -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
```
To replace a rule in the INPUT chain in the filter table, you would use the following command:
```
iptables -R INPUT 1 -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
```
To flush all of the rules in the filter table, you would use the following command:
```
iptables -F filter
```
To save the iptables rules to a file, you would use the following command:
```
iptables-save > /path/to/file
```
To restore the iptables rules from a file, you would use the following command:
```
iptables-restore < /path/to/file
```
