package model;

public class Manager1 extends Staff1 {
    private static final long serialVersionUID = 1L;

    public Manager1() {
        super();
        setViTri("Manager");
    }

    public Manager1(int id, String username, String password, String fullName, String email, String phoneNumbers) {
        super(id, username, password, fullName, email, phoneNumbers, "Manager");
    }
}

