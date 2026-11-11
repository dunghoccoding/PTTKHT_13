package model;

public class Customer1 extends Customers1 {
    private static final long serialVersionUID = 1L;

    public Customer1() {
        super();
    }

    public Customer1(int id, String username, String password, String fullName, String email, String phoneNumbers, String memberCode, int points) {
        super(id, username, password, fullName, email, phoneNumbers, memberCode, points);
    }
}

