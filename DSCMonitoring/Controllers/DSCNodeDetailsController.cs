using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DSCMonitoring.Models;
using Microsoft.AspNetCore.Mvc;

namespace DSCMonitoring.Controllers
{
    [Route("[controller]")]
    public class DscNodeDetailsController : Controller
    {
        private readonly IDSCNodeRepository dscNodeRepository;

        public DscNodeDetailsController(IDSCNodeRepository repository)
        {
            dscNodeRepository = repository;
        }
        [HttpGet("{nodename}")]
        public IActionResult Index(string nodename)
        {
            
            return View(dscNodeRepository.GetByNodeName(nodename));
        }
    }
}