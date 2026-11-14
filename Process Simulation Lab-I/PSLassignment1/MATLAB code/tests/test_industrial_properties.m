function tests=test_industrial_properties
tests=functiontests(localfunctions);
end
function testEthanolPsatInRange(testCase)
p=cps22_psat_nist(1,445.1253); verifyGreaterThan(testCase,p,1e5); verifyLessThan(testCase,p,2e6);
end
function testWaterPsatInRange(testCase)
p=cps22_psat_nist(2,445.1253); verifyGreaterThan(testCase,p,5e5); verifyLessThan(testCase,p,1.2e6);
end
function testOutOfRangeReturnsNaN(testCase)
verifyTrue(testCase,isnan(cps22_psat_nist(1,300)));
end
function testNrtlNormalizationGuard(testCase)
caught=false; try, cps22_nrtl_candidate([0.7 0.4],445,zeros(2),zeros(2),zeros(2)); catch, caught=true; end; verifyTrue(testCase,caught);
end
function testSRKRootAdmissible(testCase)
comp=struct('Tc_K',{514.7093,647.096},'Pc_Pa',{6267914.6,22064000},'omega',{0.644,0.344292});
r=cps22_srk_industrial([0.55 0.45],445.1,1.5e6,comp,0); verifyGreaterThan(testCase,r.Z,r.B); verifyTrue(testCase,all(r.phi>0));
end
