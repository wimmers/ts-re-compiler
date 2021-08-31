// Disambiguate variable names that are already bound in parent scope.
module.exports = function(babel) {
    return {
        visitor: {
            Scopable(path){
              const scope = path.scope
              const parentScope = scope.parent
              if (!parentScope) return
              for (binding in scope.bindings) {
                if (parentScope.hasBinding(binding))
                  scope.rename(binding)
              }
        	}
        }
    }
}