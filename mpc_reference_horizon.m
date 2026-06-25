function rHorizon = mpc_reference_horizon(currentK,p)
if p.reference.preview
    predictionIndices = currentK + (1:p.mpc.N);
    rHorizon = reference_signal(predictionIndices,p);
else
    rHorizon = reference_signal(currentK,p)*ones(1,p.mpc.N);
end
end
