Given(/^some time has passed$/) do
  Timecop.travel rand(1.hour..1.week).from_now
end
