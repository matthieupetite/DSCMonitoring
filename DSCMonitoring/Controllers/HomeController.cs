using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using DSCMonitoring.Models;

namespace DSCMonitoring.Controllers
{
    public class HomeController : Controller
    {
        private readonly IDSCNodeRepository dscNodeRepository;
        public HomeController(IDSCNodeRepository repository)
        {
            dscNodeRepository = repository;
        }

        public IActionResult Index()
        {

            var NodeList = dscNodeRepository.GetAll().ToList();
            double NodeInSuccessPrecentage = NodeList.Count(n => n.Status == "Success") / (double)NodeList.Count() *100;
            double NodeInFailurePrecentage = NodeList.Count(n => n.Status == "Failure") / (double)NodeList.Count() *100;

            ViewData["NodeInSuccessPrecentage"] = string.Format("{0:F2}", NodeInSuccessPrecentage);
            ViewData["NodeInFailurePrecentage"] = string.Format("{0:F2}", NodeInFailurePrecentage);

            return View(NodeList);
        }


        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
