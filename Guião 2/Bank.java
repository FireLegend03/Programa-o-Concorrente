public class Bank {

    private static class Account {
        private int balance;
        Account(int balance) { this.balance = balance; }
        synchronized int balance() { return balance; }
        synchronized boolean deposit(int value) {
            balance += value;
            return true;
        }
        synchronized boolean withdraw(int value) {
            if (value > balance)
                return false;
            balance -= value;
            return true;
        }
    }

    // Bank slots and vector of accounts
    private int slots;
    private Account[] av; 

    public Bank(int n) {
        slots=n;
        av=new Account[slots];
        for (int i=0; i<slots; i++) av[i]=new Account(0);
    }

    // Account balance
    public int balance(int id) {
        if (id < 0 || id >= slots)
            return 0;
        return av[id].balance();
    }

    // Deposit
    public boolean deposit(int id, int value) {
        if (id < 0 || id >= slots)
            return false;
        return av[id].deposit(value);
    }

    // Withdraw; fails if no such account or insufficient balance
    public boolean withdraw(int id, int value) {
        if (id < 0 || id >= slots)
            return false;
        return av[id].withdraw(value);
    }

    // Transferencia
    public boolean transfer(int from, int to, int value){
        if (from < 0 || from >= slots || to < 0 || to > slots){
            return false;
        }
        Account af = av[Math.min(from, to)];
        Account at = av[Math.max(from, to)];

        synchronized(af){
            synchronized(at){
                return av[from].withdraw(value) && av[to].deposit(value);
            }
        }
    }

    public int totalBalance(){
        int sum = 0;
        for(Account a : av){
            sum += a.balance();
        }
        return sum;
    }
}


