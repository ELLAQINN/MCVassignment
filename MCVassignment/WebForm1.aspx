<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="MCVassignment.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
        </div>
    </form>
</body>
</html>
using System;
using System.Linq;
using System.Web.Mvc;
using YourNamespace.Models;

public class InsureeController : Controller
{
    private YourDbContext db = new YourDbContext();

    // GET: Insuree/Create
    public ActionResult Create()
    {
        return View();
    }

    // POST: Insuree/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public ActionResult Create([Bind(Include = "Id,FirstName,LastName,EmailAddress,DateOfBirth,CarYear,CarMake,CarModel,SpeedingTickets,DUI,CoverageType")] Insuree insuree)
    {
        if (ModelState.IsValid)
        {
            insuree.Quote = CalculateQuote(insuree);
            db.Insurees.Add(insuree);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        return View(insuree);
    }

    private decimal CalculateQuote(Insuree insuree)
    {
        decimal baseQuote = 50m;

        // Calculate age
        int age = DateTime.Now.Year - insuree.DateOfBirth.Year;
        if (DateTime.Now.DayOfYear < insuree.DateOfBirth.DayOfYear)
            age--;

        // Age-based calculations
        if (age <= 18)
            baseQuote += 100;
        else if (age >= 19 && age <= 25)
            baseQuote += 50;
        else
            baseQuote += 25;

        // Car year calculations
        if (insuree.CarYear < 2000)
            baseQuote += 25;
        else if (insuree.CarYear > 2015)
            baseQuote += 25;

        // Car make and model calculations
        if (insuree.CarMake.ToLower() == "porsche")
        {
            baseQuote += 25;
            if (insuree.CarModel.ToLower() == "911 carrera")
                baseQuote += 25;
        }

        // Speeding tickets calculation
        baseQuote += insuree.SpeedingTickets * 10;

        // DUI calculation
        if (insuree.DUI)
            baseQuote *= 1.25m;

        // Coverage type calculation
        if (insuree.CoverageType)
            baseQuote *= 1.50m;

        return baseQuote;
    }

    // GET: Insuree/Admin
    public ActionResult Admin()
    {
        var insurees = db.Insurees.ToList();
        return View(insurees);
    }

    // Add other actions (Index, Details, Edit, Delete, etc.) as needed
}
