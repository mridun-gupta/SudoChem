function hex = sha256_file(filePath)
%SHA256_FILE Calculate a SHA-256 digest using the MATLAB JVM.
% A missing JVM is a hard error because integrity verification is mandatory.
if exist(filePath, 'file') ~= 2
    error('ENERGY008:HashFileMissing', 'Cannot hash a missing file: %s', filePath);
end
if ~(usejava('jvm'))
    error('ENERGY008:HashUnavailable', ...
        'SHA-256 verification requires the MATLAB JVM in this startup build. Enable a JVM-capable MATLAB session; do not disable hash verification.');
end
fid = fopen(filePath, 'rb');
if fid < 0
    error('ENERGY008:HashReadFailed', 'Cannot open file for SHA-256: %s', filePath);
end
cleaner = onCleanup(@() fclose(fid));
md = java.security.MessageDigest.getInstance('SHA-256');
while true
    bytes = fread(fid, 1024*1024, '*uint8');
    if isempty(bytes), break; end
    md.update(typecast(bytes(:), 'int8'));
end
digest = typecast(md.digest(), 'uint8');
hex = lower(reshape(dec2hex(digest,2).',1,[]));
clear cleaner;
end
