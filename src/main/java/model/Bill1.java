package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Bill1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String dateTime;
    private float totalAmount;
    private String paymentMethod;
    private float discount;
    private Customers1 customer;
    private SalePerson1 salePerson;
    private List<Ticket1> dsTicket = new ArrayList<>();

    public Bill1() {
    }

    public Bill1(int id, String dateTime, float totalAmount, String paymentMethod, float discount, Customers1 customer, SalePerson1 salePerson) {
        this.id = id;
        this.dateTime = dateTime;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.discount = discount;
        this.customer = customer;
        this.salePerson = salePerson;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime;
    }

    public float getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(float totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public float getDiscount() {
        return discount;
    }

    public void setDiscount(float discount) {
        this.discount = discount;
    }

    public Customers1 getCustomer() {
        return customer;
    }

    public void setCustomer(Customers1 customer) {
        this.customer = customer;
    }

    public SalePerson1 getSalePerson() {
        return salePerson;
    }

    public void setSalePerson(SalePerson1 salePerson) {
        this.salePerson = salePerson;
    }

    public List<Ticket1> getDsTicket() {
        return dsTicket;
    }

    public void setDsTicket(List<Ticket1> dsTicket) {
        this.dsTicket = dsTicket;
    }
}

