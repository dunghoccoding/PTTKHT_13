package model;

public class Staff1 extends User1 {
    private static final long serialVersionUID = 1L;

    private String viTri;

    public Staff1() {
        super();
    }

    public Staff1(int id, String username, String password, String fullName, String email, String phoneNumbers, String viTri) {
        super(id, username, password, fullName, email, phoneNumbers);
        this.viTri = viTri;
    }

    public String getViTri() {
        return viTri;
    }

    public void setViTri(String viTri) {
        this.viTri = viTri;
    }
}

