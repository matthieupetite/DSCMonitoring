using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DSCMonitoring.Models;
using Microsoft.AspNetCore.Mvc;

namespace DSCMonitoring.Controllers
{
    [Route("api")]
    public class DSCNodeController : Controller
    {

        private readonly IDSCNodeRepository dscNodeRepository;

        public DSCNodeController(IDSCNodeRepository repository)
        {
            dscNodeRepository = repository;
        }

        [HttpGet]
        public IEnumerable<DSCNode> Get()
        {
            return dscNodeRepository.GetAll();
        }

        [HttpGet("{nodename}")]
        public DSCNodeDetails Get(string nodename)
        {
            return dscNodeRepository.GetByNodeName(nodename);
        }

        [HttpGet("GetStatus/{nodename}")]
        public IActionResult GetStatus(string nodename)
        {
            DSCNodeDetails myNode = dscNodeRepository.GetByNodeName(nodename);
            if (myNode == null)
            {
                return NotFound();
            }
            if (myNode.Status == "Success")
            {
                return StatusCode(200, myNode);
            }
            else
            {
                return StatusCode(500,myNode);
            }

        }
    }
}