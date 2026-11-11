package model;

import java.util.ArrayList;
import java.util.List;

public class Customers1 extends User1 {
    private static final long serialVersionUID = 1L;

    private String memberCode;
    private int points;
    private List<Bill1> dsBill = new ArrayList<>();

    public Customers1() {
        super();
    }

    public Customers1(int id, String username, String password, String fullName, String email, String phoneNumbers, String memberCode, int points) {
        super(id, username, password, fullName, email, phoneNumbers);
        this.memberCode = memberCode;
        this.points = points;
    }

    public String getMemberCode() {
        return memberCode;
    }

    public void setMemberCode(String memberCode) {
        this.memberCode = memberCode;
    }

    public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }

    public List<Bill1> getDsBill() {
        return dsBill;
    }

    public void setDsBill(List<Bill1> dsBill) {
        this.dsBill = dsBill;
    }
}

