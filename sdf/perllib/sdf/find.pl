########## Find Routines ##########

use File::Find;

# Global state used by find_dirs
my $_find_dirs_base = '';
my $_find_dirs_file_rule = '';
my $_find_dirs_exclude_dir_rule = '';
my $_find_dirs_sep = '';
my @_find_dirs_found = ();
my %_find_dirs_found = ();

# File the set of sub-directories in a directory which satisfy the
# matching rules. Names are returned relative to the base directory.
# If a 4th argument is provided, that string is used to separate directory
# names, otherwise the directory separator for the current OS is used.
sub find_dirs {
    $_find_dirs_base = shift;
    my $file_rule = shift;
    $_find_dirs_exclude_dir_rule = shift;
    $_find_dirs_sep = shift || $NAME_DIR_SEP || '/';

    $_find_dirs_file_rule = $file_rule eq '' ? '-f' : "-f && $file_rule";
    @_find_dirs_found = ();
    %_find_dirs_found = ();
    find(\&_wanted_for_find_dirs, $_find_dirs_base);
    return @_find_dirs_found;
}
sub _wanted_for_find_dirs {
    local ($dir, $file);

    $dir = $File::Find::dir;
    if ($dir ne '' && $_find_dirs_exclude_dir_rule ne '') {
        $file = $_;
        my @parts = split(/\//, $dir);
        $_ = pop(@parts);
        if (eval $_find_dirs_exclude_dir_rule) {
            $File::Find::prune = 1;
        }
        # Make sure we restore $_
        $_ = $file;
        return if $File::Find::prune;
    }

    if (eval $_find_dirs_file_rule) {
        return if $_find_dirs_found{$dir};
        $_find_dirs_found{$dir}++;
        $dir = substr($dir, length($_find_dirs_base) + 1);
        $dir =~ s#/#$_find_dirs_sep#g;
        push(@_find_dirs_found, $dir);
    }
}

# Global state used by find_files
my $_find_files_base = '';
my $_find_files_rule = '';
my $_find_files_exclude_dir_rule = '';
my @_find_files_found = ();

# File the set of files in a single directory which
# satisfy the nominated rule. Names are returned relative to the
# base directory.
sub find_files {
    $_find_files_base = shift;
    my $matching = shift;
    $_find_files_exclude_dir_rule = shift;

    $_find_files_rule = $matching ne '' ? "-f && $matching" : "-f";
    @_find_files_found = ();
    find(\&_wanted_for_file_files, $_find_files_base);
    return @_find_files_found;
}
sub _wanted_for_file_files {
    local ($dir, $file);

    $dir = $File::Find::dir;
    if ($dir ne '' && $_find_files_exclude_dir_rule ne '') {
        $file = $_;
        my @parts = split(/\//, $dir);
        $_ = pop(@parts);
        if (eval $_find_files_exclude_dir_rule) {
            $File::Find::prune = 1;
        }
        # Make sure we restore $_
        $_ = $file;
        return if $File::Find::prune;
    }

    if (eval $_find_files_rule) {
        my $name = $File::Find::name;
        $name = substr($name, length($_find_files_base) + 1);
        $name =~ s#/#$NAME_DIR_SEP#g if $NAME_OS ne 'unix';
        push(@_find_files_found, $name);
    }
}

# package return value
1;
