#ifndef VIENNACL_DEVICE_SPECIFIC_TREE_PARSING_TRAVERSE_HPP
#define VIENNACL_DEVICE_SPECIFIC_TREE_PARSING_TRAVERSE_HPP

/* =========================================================================
   Copyright (c) 2010-2013, Institute for Microelectronics,
                            Institute for Analysis and Scientific Computing,
                            TU Wien.
   Portions of this software are copyright by UChicago Argonne, LLC.

                            -----------------
                  ViennaCL - The Vienna Computing Library
                            -----------------

   Project Head:    Karl Rupp                   rupp@iue.tuwien.ac.at

   (A list of authors and contributors can be found in the PDF manual)

   License:         MIT (X11), see file LICENSE in the base directory
============================================================================= */


/** @file viennacl/generator/helpers.hpp
    @brief several code generation helpers
*/

#include <set>

#include "CL/cl.h"

#include "viennacl/forwards.h"

#include "viennacl/scheduler/forwards.h"

#include "viennacl/device_specific/utils.hpp"
#include "viennacl/device_specific/forwards.h"

namespace viennacl{

  namespace device_specific{

    namespace tree_parsing{

      /** @brief base functor class for traversing a statement */
      class traversal_functor{
        public:
          void call_before_expansion(scheduler::statement_node const *) const { }
          void call_after_expansion(scheduler::statement_node const *) const { }
      };

      /** @brief Recursively execute a functor on a statement */
      template<class Fun>
      static void traverse(scheduler::statement const & statement, scheduler::statement_node const & root_node, Fun const & fun, bool recurse_structurewise_function /* see forwards.h for default argument */){
        bool recurse = recurse_structurewise_function || !utils::cannot_inline(root_node.op);

        fun.call_before_expansion(&root_node);

        //Lhs:
        if(recurse){
          if(root_node.lhs.type_family==scheduler::COMPOSITE_OPERATION_FAMILY)
            traverse(statement, statement.array()[root_node.lhs.node_index], fun, recurse_structurewise_function);
          if(root_node.lhs.type_family != scheduler::INVALID_TYPE_FAMILY)
            fun(&statement, &root_node, LHS_NODE_TYPE);
        }

        //Self:
        fun(&statement, &root_node, PARENT_NODE_TYPE);

        //Rhs:
        if(recurse && root_node.op.type_family!=scheduler::OPERATION_UNARY_TYPE_FAMILY){
          if(root_node.rhs.type_family==scheduler::COMPOSITE_OPERATION_FAMILY)
            traverse(statement, statement.array()[root_node.rhs.node_index], fun, recurse_structurewise_function);
          if(root_node.rhs.type_family != scheduler::INVALID_TYPE_FAMILY)
            fun(&statement, &root_node, RHS_NODE_TYPE);
        }

        fun.call_after_expansion(&root_node);


      }

    }
  }
}
#endif