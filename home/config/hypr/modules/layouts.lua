-- Available for experiments; dwindle remains the active layout.
hl.layout.register("balanced", {
    recalculate = function(context)
        local count = #context.targets
        for index, target in ipairs(context.targets) do
            target:place(context:column(index - 1, count))
        end
    end,
})
