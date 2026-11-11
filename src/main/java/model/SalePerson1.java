package model;

import java.util.ArrayList;
import java.util.List;

public class SalePerson1 extends Staff1 {
    private static final long serialVersionUID = 1L;

    private List<Bill1> dsBill = new ArrayList<>();

    public SalePerson1() {
        super();
        setViTri("Salesperson");
    }

    public SalePerson1(int id, String username, String password, String fullName, String email, String phoneNumbers) {
        super(id, username, password, fullName, email, phoneNumbers, "Salesperson");
    }

    public List<Bill1> getDsBill() {
        return dsBill;
    }

    public void setDsBill(List<Bill1> dsBill) {
        this.dsBill = dsBill;
    }
}

